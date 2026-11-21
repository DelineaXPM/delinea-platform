#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# CONFIG – adjust as needed
# -------------------------------
OUT_DIR="./fusion_jwt_cert"
KEY_SIZE=2048
DAYS_VALID=365

# Subject values are not validated by Fusion, but keep them sane
COUNTRY="US"
STATE="test"
LOCALITY="test"
ORG="test"
ORG_UNIT="test"
COMMON_NAME="fusion-jwt-client"

PFX_PASSWORD=''   # Set empty to be prompted: PFX_PASSWORD=''

# -------------------------------
# PREP
# -------------------------------
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"
echo "Output directory: $(pwd)"

# -------------------------------
# 1) Generate RSA private key (modern OpenSSL)
# -------------------------------
echo "Generating private key (RSA ${KEY_SIZE})..."
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:"$KEY_SIZE" -out private.key

# -------------------------------
# 2) Generate self-signed X.509 cert using SHA-256
#    This is the key change for Option A.
# -------------------------------
echo "Generating self-signed certificate (SHA-256)..."
openssl req -new -x509 -sha256 \
  -key private.key \
  -out public.pem \
  -days "$DAYS_VALID" \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME"

# -------------------------------
# 3) Convert cert to DER (.cer)
#    (Upload this to Fusion: Inbound API Authentication Public Certificates)
# -------------------------------
echo "Converting certificate to DER (.cer)..."
openssl x509 -in public.pem -outform DER -out public.cer

# -------------------------------
# 4) Create PKCS#12 (PFX) with modern encryption defaults
#    This reduces odds of Windows import / provider issues.
# -------------------------------
echo "Creating PFX bundle..."
if [[ -n "$PFX_PASSWORD" ]]; then
  openssl pkcs12 -export \
    -inkey private.key \
    -in public.pem \
    -out jwtclient.pfx \
    -password "pass:$PFX_PASSWORD" \
    -keypbe AES-256-CBC \
    -certpbe AES-256-CBC \
    -macalg SHA256
else
  # Prompt interactively
  openssl pkcs12 -export \
    -inkey private.key \
    -in public.pem \
    -out jwtclient.pfx \
    -keypbe AES-256-CBC \
    -certpbe AES-256-CBC \
    -macalg SHA256
fi

# -------------------------------
# 5) Display certificate details
# -------------------------------
echo
echo "Certificate details:"
openssl x509 -in public.pem -noout -subject -issuer -dates -text | sed -n '1,80p'

# Confirm signature algorithm is sha256WithRSAEncryption
echo
echo "Signature algorithm check:"
openssl x509 -in public.pem -noout -text | awk '/Signature Algorithm/ {print; exit}'

# -------------------------------
# 6) Print SHA1 thumbprint (for x5t verification)
# -------------------------------
echo
echo "SHA1 thumbprint (for x5t calculation / x5t header):"
openssl x509 -in public.pem -noout -fingerprint -sha1

# -------------------------------
# 7) Quick modulus match check (private key matches cert)
# -------------------------------
echo
echo "Modulus check (these MD5 hashes must match):"
openssl pkey -in private.key -pubout | openssl md5
openssl x509 -in public.pem -noout -pubkey | openssl md5
openssl x509 -in public.cer -inform DER -out public_fusion.cer -outform PEM

echo
echo "Files created:"
ls -1
