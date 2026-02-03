docker run --rm -it \
  -v /data/docker/certs:/etc/letsencrypt \
  -v ~/nixos-cfg/.keys/cloudflare.ini:/etc/cloudflare/credentials.ini:ro \
  certbot/dns-cloudflare certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /etc/cloudflare/credentials.ini \
  -d "*.cxbrgr.com" -d "cxbrgr.com" \
  -d "*.stream.cxbrgr.com" \
  --expand