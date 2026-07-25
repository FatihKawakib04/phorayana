# Spesifikasi Fitur: Email OTP Registration & Autentikasi

Dokumen ini mendeskripsikan spesifikasi teknis dan alur pengguna untuk fitur pendaftaran akun berbasis 6-Digit Email OTP (`verifyOtp`) serta kontrol akses pengguna pada aplikasi Phorayana.

---

## 1. Alur Pendaftaran (Email OTP)

```mermaid
sequenceDiagram
    participant User as Commuter
    participant UI as login.vue
    participant Auth as Supabase Auth
    participant DB as Profiles DB

    User->>UI: Input Email & Password -> Klik "Daftar"
    UI->>Auth: supabase.auth.signUp({ email, password })
    Auth-->>UI: Kirim Kode 6-Digit OTP ke Email
    UI->>UI: Tampilkan Modal OTP & Jalankan Timer Countdown 60s
    User->>UI: Input 6-Digit Pin OTP -> Klik "Verifikasi"
    UI->>Auth: supabase.auth.verifyOtp({ email, token, type: 'signup' })
    alt OTP Valid
        Auth-->>UI: Session Token (JWT) Issued
        UI->>DB: Upsert Profile (role_id = ID Role 'user')
        UI-->>User: Redirect ke Dashboard Utama (/)
    else OTP Invalid / Expired
        Auth-->>UI: Verification Failed
        UI-->>User: Tampilkan Pesan Kesalahan & Opsi Kirim Ulang (setelah 60s)
    end
```

---

## 2. Spesifikasi Antarmuka UI (`login.vue`)

1. **Modal State Verification**:
   - Modal OTP muncul otomatis setelah request `signUp` berhasil disetujui server.
   - Menyediakan 6-digit PIN input field dengan auto-focus.
2. **Countdown Timer 60 Detik**:
   - Timer countdown 60 detik (`resendTimer`) mencegah spam request pengiriman ulang OTP.
   - Tombol "Kirim Ulang OTP" nonaktif (*disabled*) selama timer berjalan.
3. **Default Role Assignment**:
   - Setiap pengguna baru yang menyelesaikan `verifyOtp` otomatis dibuatkan baris profil dengan `role_id` merujuk ke peranan `'user'`.
