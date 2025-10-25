param(
    [Parameter(Mandatory=$true)]
    [string]$IP
)

# Check if OpenSSL is installed
function Test-OpenSSL {
    try {
        $null = & openssl version 2>$null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# Install OpenSSL
function Install-OpenSSL {
    Write-Host "OpenSSL not found. Installing..." -ForegroundColor Yellow
    
    # Try Chocolatey first
    try {
        $null = & choco --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Installing via Chocolatey..."
            choco install openssl -y
            refreshenv
            return
        }
    } catch {}
    
    # Manual install
    Write-Host "Chocolatey not available. Please install OpenSSL manually (64-bit):" -ForegroundColor Yellow
    Write-Host "-- Download Win32/Win64 OpenSSL --" -ForegroundColor Cyan
    Write-Host "-> https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Cyan
    Write-Host "After installation, restart PowerShell and run this script again."
    exit 1
}

# Check and install OpenSSL if needed
if (-not (Test-OpenSSL)) {
    Install-OpenSSL
    
    # Verify after install
    if (-not (Test-OpenSSL)) {
        Write-Host "OpenSSL installation failed. Please install manually." -ForegroundColor Red
        exit 1
    }
}

Write-Host "OpenSSL is ready. Generating certificates for IP: $IP" -ForegroundColor Green

# Create subdirectory for certificate files
if (Test-Path certs) {
    Remove-Item certs -Recurse -Force
}
New-Item -ItemType Directory -Path certs | Out-Null

# Certificate generation variables
$caCn = "Novitus Printer Root CA"
$fiscalPrinterIp = $IP

# Generate custom Root CA
openssl genrsa -out "certs\rootCA.key" 4096

# Generate custom Root CA certificate
openssl req -x509 -new -noenc `
    -key "certs\rootCA.key" -sha256 `
    -days 3650 `
    -out "certs\rootCA.crt" `
    -subj "/CN=$caCn/O=Directo/C=EE"

# Generate private key for specific fiscal printer
openssl genrsa -out "certs\server.key" 2048

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
"@ | Out-File -FilePath "certs\server.conf" -Encoding utf8

# Generate CSR using the config
openssl req -new `
  -key "certs\server.key" `
  -out "certs\server.csr" `
  -config "certs\server.conf"

# Generate certificate using the CSR
openssl x509 -req -in "certs\server.csr" `
  -CA "certs\rootCA.crt" `
  -CAkey "certs\rootCA.key" `
  -CAcreateserial `
  -out "certs\server.crt" `
  -days 3650 `
  -sha256 `
  -extensions req_ext `
  -extfile "certs\server.conf"

# Add the custom Root CA to certificate store
certutil -delstore -enterprise root $caCn
certutil -addstore -enterprise "Root" "certs\rootCA.crt"

# Convert to .pfx (THIS GOES IN CURRENT DIRECTORY)
openssl pkcs12 -export `
    -out server.pfx `
    -inkey "certs\server.key" `
    -in "certs\server.crt" `
    -passout pass: `
    -certfile "certs\rootCA.crt"

Write-Host "Done! server.pfx created in current directory" -ForegroundColor Green
Write-Host "All other certificate files stored in: .\certs" -ForegroundColor Cyan