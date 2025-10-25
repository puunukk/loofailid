# Novitus printeri sertifikaatide generaator

## 1. Ettevalmistus (ainult esimesel korral)

### OpenSSL install

1. Laadi alla OpenSSL: [https://slproweb.com/products/Win32OpenSSL.html](https://slproweb.com/products/Win32OpenSSL.html)
2. Installi OpenSSL
3. **Ava PowerShell administraatorina** (parem klõps → "Run as Administrator")
4. Lisa OpenSSL keskkonnamuutujasse:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSL-Win64\bin", [EnvironmentVariableTarget]::Machine)
   ```
5. **Sulge PowerShell täielikult**

### Skriptide lubamine

1. **Ava PowerShell administraatorina**
2. Luba skriptide käivitamine:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 2. Kasutamine

1. **Ava PowerShell administraatorina**
2. Navigeeri `loo.ps1` faili asukohta:
   ```powershell
   cd D:\DEV\novitus
   ```
3. Käivita skript printeri IP-aadressiga:
   ```powershell
   .\loo.ps1 -ip 192.168.1.100
   ```

## Väljund

- `server.pfx` - põhifail printeri jaoks
- `certs\` - kõik muud sertifikaadifailid

## Skriptifailid

- `loo.ps1` - Meie täiustatud versioon (automaatne OpenSSL kontroll)
- `skript.ps1` - Algne firmapoolne versioon
