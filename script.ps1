# Useful variables
$caCn = "Novitus Printer Root CA"
$fiscalPrinterIp = "10.10.10.78"

#
# Custom Root CA
#
# Generate custom Root CA
openssl genrsa -out rootCA.key 4096

# Generate custom Root CA certificate
openssl req -x509 -new -noenc `
    -key rootCA.key -sha256 `
    -days 3650 `
    -out rootCA.crt `
    -subj "/CN=$caCn/O=Directo/C=EE"

# Generate private key for specific fiscal printer
openssl genrsa -out server.key 2048

#
# Fiscal Printer Server Certificate
#
# Create config file for SAN
@"
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
CN = $fiscalPrinterIp
O = Directo
C = EE

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = $fiscalPrinterIp
"@ | Out-File -FilePath "server.conf" -Encoding utf8

# Generate CSR using the config
openssl req -new `
  -key server.key `
  -out server.csr `
  -config server.conf

# Generate certificate using the CSR
openssl x509 -req -in server.csr `
  -CA rootCA.crt `
  -CAkey rootCA.key `
  -CAcreateserial `
  -out server.crt `
  -days 3650 `
  -sha256 `
  -extensions req_ext `
  -extfile server.conf

# Use certutil (requires administrator privileges) to add the custom Root CA 
# to the computers certificate store otherwise the HTTPS connection will not 
# work as the computer does not the certificate presented by the fiscal printer.
certutil -delstore -enterprise root $caCn
certutil -addstore -enterprise "Root" rootCA.crt

# Convert our server.crt and server.key into a .pfx which will then be given
# to Wiking2
openssl pkcs12 -export `
    -out server.pfx `
    -inkey server.key `
    -in server.crt `
    -passout pass: `
    -certfile rootCA.crt