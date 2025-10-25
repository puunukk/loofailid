# Novitus printeri sertifikaatide generaator

## Kasutamine

1. Luba skriptide käivitamine:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

2. Kopeeri fail `loo.ps1` oma arvutisse

3. Ava PowerShell ja navigeeri `loo.ps1` faili asukohta

4. Käivita skript:
```powershell
.\loo.ps1 -ip 192.168.1.100
```

## Allalaadimised

**OpenSSL (64-bit):** https://slproweb.com/products/Win32OpenSSL.html

## Väljund

- `server.pfx` - põhifail printeri jaoks
- `certs\` - kõik muud sertifikaadifailid