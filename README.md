# Desktop Browser for iPhone

ต้นแบบแอปเบราว์เซอร์ iOS ที่ขอเว็บไซต์โหมด Desktop และมีหลายแท็บ พัฒนาด้วย SwiftUI + WKWebView

## ฟีเจอร์

- หลายแท็บ พร้อมเพิ่ม เลือก และปิดแท็บ
- ช่อง URL/ค้นหา Google
- ย้อนกลับ ไปข้างหน้า รีโหลด และหยุดโหลด
- ขอหน้าเว็บแบบ Desktop ด้วย `preferredContentMode = .desktop`
- แถบความคืบหน้าการโหลด
- ดาวน์โหลดไฟล์ลง Documents/Downloads ของแอป พร้อมเปอร์เซ็นต์ความคืบหน้าและหยุดชั่วคราว/ต่อได้
- เปิด Share Sheet หลังดาวน์โหลดสำเร็จ
- เว็บที่เปิดหน้าต่างใหม่ (window.open หรือ target="_blank") จะเปิดเป็นแท็บใหม่
- รองรับแนวตั้งและแนวนอน
- ปฏิเสธ URL scheme ที่ไม่ใช่ HTTP/HTTPS และ scheme ภายในที่จำเป็น

## เปิดโปรเจกต์

ต้องใช้ macOS และ Xcode 16 หรือใหม่กว่า:

1. เปิด `DesktopBrowser.xcodeproj`
2. เลือก Target `DesktopBrowser`
3. ที่ Signing & Capabilities เลือก Apple Developer Team ของคุณ
4. เปลี่ยน Bundle Identifier จาก `com.example.DesktopBrowser` ให้ไม่ซ้ำ
5. เลือก iPhone หรือ Simulator แล้วกด Run

## ทำงานจาก iPhone

- อัปโหลดโฟลเดอร์นี้ไป GitHub
- แก้ไฟล์ผ่าน `github.dev` หรือ GitHub Codespaces ใน Safari
- GitHub Actions ที่แนบมาจะตรวจว่าโปรเจกต์ build ผ่านบน macOS runner
- การติดตั้งลง iPhone จริงยังต้องมีการ code signing ด้วยบัญชี Apple Developer และการจัดการ certificate/provisioning profile

## ข้อจำกัด

- Desktop mode คือการขอเนื้อหาแบบเดสก์ท็อป ไม่ได้ทำให้หน้าจอ iPhone มีขนาดเท่าจอคอม
- บางเว็บไซต์ใช้ responsive layout ตามความกว้างจริง จึงอาจยังจัดหน้าแบบมือถือ
- ระบบดาวน์โหลด pause/resume ใช้ resume data จาก WebKit ถ้าเซิร์ฟเวอร์ไม่รองรับ range request จะหยุดชั่วคราวไม่ได้ (ถือว่าไม่สำเร็จ)
- ก่อนส่ง App Store ต้องมีนโยบายความเป็นส่วนตัว ทดสอบความปลอดภัย และตรวจข้อกำหนด App Review (ไอคอนแอปมีแล้วใน `Assets.xcassets/AppIcon.appiconset`)
