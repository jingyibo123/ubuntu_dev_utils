#!/usr/bin/env bash
set -Eeuo pipefail

# 用法：
#   sudo PROXY=127.0.0.1:3128 bash harvest-ca-and-sync-snapd.sh
#   sudo PROXY=127.0.0.1:3128 bash harvest-ca-and-sync-snapd.sh api.snapcraft.io canonical-lgw01.cdn.snapcraftcontent.com
#
# 默认会检查：
#   - api.snapcraft.io
#   - canonical-lgw01.cdn.snapcraftcontent.com

PROXY="${PROXY:-127.0.0.1:3128}"
DEST_DIR="${DEST_DIR:-/usr/local/share/ca-certificates/proxy-auto}"
WORKDIR="${WORKDIR:-/tmp/proxy-cert-harvest}"
HOSTS=("$@")

if [[ ${#HOSTS[@]} -eq 0 ]]; then
  HOSTS=(
    "api.snapcraft.io"
    "canonical-lgw01.cdn.snapcraftcontent.com"
  )
fi

log() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*" >&2
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "缺少命令: $1" >&2
    exit 1
  }
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "请用 root 运行，例如：sudo bash $0" >&2
    exit 1
  fi
}

split_pem_chain() {
  local input="$1"
  local outdir="$2"
  mkdir -p "$outdir"

  awk -v dir="$outdir" '
    /-----BEGIN CERTIFICATE-----/ {
      in_cert=1
      n++
      file=sprintf("%s/cert-%02d.pem", dir, n)
    }
    in_cert {
      print > file
    }
    /-----END CERTIFICATE-----/ {
      in_cert=0
      close(file)
    }
  ' "$input"
}

fetch_chain() {
  local host="$1"
  local outdir="$WORKDIR/$host"
  mkdir -p "$outdir"

  log "通过代理 ${PROXY} 抓取 $host 的证书链"
  # 不因为握手失败而中止；很多时候即使 verify 失败也能拿到链
  openssl s_client \
    -proxy "$PROXY" \
    -connect "${host}:443" \
    -servername "$host" \
    -showcerts \
    </dev/null >"$outdir/s_client.txt" 2>&1 || true

  split_pem_chain "$outdir/s_client.txt" "$outdir"

  if ! compgen -G "$outdir/cert-*.pem" >/dev/null; then
    log "没有从 $host 抓到任何证书"
    return 1
  fi
}

cert_is_ca() {
  local pem="$1"
  local text subject issuer

  text="$(openssl x509 -in "$pem" -noout -text 2>/dev/null || true)"

  # 首选：明确有 CA:TRUE
  if grep -Eq 'CA:TRUE' <<<"$text"; then
    return 0
  fi

  # 兜底：某些旧证书可能没有 basicConstraints，但自签+具备签发能力
  subject="$(openssl x509 -in "$pem" -noout -subject -nameopt RFC2253 2>/dev/null | sed 's/^subject=//')"
  issuer="$(openssl x509 -in "$pem" -noout -issuer  -nameopt RFC2253 2>/dev/null | sed 's/^issuer=//')"

  if [[ -n "$subject" && "$subject" == "$issuer" ]] && grep -Eq 'Certificate Sign|keyCertSign' <<<"$text"; then
    return 0
  fi

  return 1
}

cert_not_expired() {
  local pem="$1"
  openssl x509 -in "$pem" -checkend 0 -noout >/dev/null 2>&1
}

cert_subject_one_line() {
  local pem="$1"
  openssl x509 -in "$pem" -noout -subject -nameopt RFC2253 2>/dev/null | sed 's/^subject=//'
}

install_ca_cert() {
  local pem="$1"
  local fp dst

  fp="$(openssl x509 -in "$pem" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d ':')"
  dst="$DEST_DIR/auto-ca-${fp}.crt"

  if [[ -f "$dst" ]]; then
    log "已存在: $dst"
    return 0
  fi

  install -D -m 0644 "$pem" "$dst"
  log "已安装 CA 到系统目录: $dst"
  log "  Subject: $(cert_subject_one_line "$pem")"
}

harvest_and_install_host_cas() {
  local host="$1"
  local dir="$WORKDIR/$host"
  local pem
  local found=0

  fetch_chain "$host" || true

  shopt -s nullglob
  for pem in "$dir"/cert-*.pem; do
    if cert_is_ca "$pem" && cert_not_expired "$pem"; then
      install_ca_cert "$pem"
      found=1
    else
      log "跳过非 CA 或已过期证书: $pem"
    fi
  done
  shopt -u nullglob

  if [[ "$found" -eq 0 ]]; then
    log "在 $host 的链中没有找到可导入的 CA 证书"
  fi
}

update_system_ca_store() {
  log "更新系统证书库"
  update-ca-certificates
}

sync_snapd_store_certs() {
  local crt key
  local count=0

  log "同步系统目录中的 CA 到 snapd store-certs"

  shopt -s nullglob
  for crt in "$DEST_DIR"/*.crt; do
    key="auto-$(sha256sum "$crt" | cut -c1-16)"
    snap set system "store-certs.$key=$(cat "$crt")"
    ((count+=1))
  done
  shopt -u nullglob

  log "已同步 $count 张证书到 snapd"
  systemctl restart snapd
  systemctl restart snapd.socket || true

  log "检查 snapd 到 store 的连通性"
  snap debug connectivity || true
}

main() {
  require_root
  need_cmd openssl
  need_cmd update-ca-certificates
  need_cmd snap
  need_cmd sha256sum
  need_cmd awk
  need_cmd sed
  need_cmd install

  mkdir -p "$DEST_DIR" "$WORKDIR"

  for host in "${HOSTS[@]}"; do
    harvest_and_install_host_cas "$host"
  done

  update_system_ca_store
  sync_snapd_store_certs

  log "完成。你现在可以再试：snap install tmux --classic"
}

main "$@"
