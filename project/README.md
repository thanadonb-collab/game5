# Adventurer Quest — แบบฝึกหัดที่ 5: First 3D Game

เกม 3D Platformer 2 ด่าน พัฒนาด้วย **Godot 4.7.2** โดยต่อยอดจาก **3D Platformer Starter Kit (SD Studios)**

## วิธีเล่น
| ปุ่ม | การทำงาน |
|---|---|
| W A S D / ลูกศร | เดิน |
| SPACE | กระโดด (กดอีกครั้งกลางอากาศ = ตีลังกา / Double Jump) |
| เมาส์ หรือ Q / E | หมุนกล้อง |
| ล้อเมาส์ | ซูมกล้อง |
| P | หยุดเกม |
| ESC | ปล่อยเมาส์ (คลิกที่จอเพื่อควบคุมกล้องอีกครั้ง) |

**เป้าหมาย:** เก็บเหรียญในด่านให้ครบ → ประตูจะเปิด (ไฟเปลี่ยนจากแดงเป็นเขียว) → เดินเข้าประตูเพื่อไปด่านถัดไป
มี 3 ชีวิตต่อด่าน โดนกับดักหรือตกน้ำจะเสีย 1 ชีวิตแล้วกลับไปที่ Checkpoint ล่าสุด

## ด่าน
1. **Sunny Meadow (ทุ่งหญ้าสดใส)** — 10 เหรียญ · หนามโผล่ตามจังหวะ, แท่นเลื่อน, ท่อนไม้หมุน
2. **Autumn Twilight (ป่าใบไม้แดงยามพลบค่ำ)** — 11 เหรียญ · พื้นถล่ม, ท่อนไม้หมุนคู่, ลิฟต์ขึ้นลง, ทางเดินหนามแบบคลื่น, แท่นเลื่อนด้านข้าง

## สิ่งที่ปรับจาก Starter Kit
- **ตัวละคร:** เปลี่ยนจาก Gobot เป็น *Adventurer* (Quaternius, poly.pizza) และสร้าง AnimationLibrary ใหม่ (`Assets/Models/Adventurer/AdventurerAnims.tres`) ให้ชื่อท่าตรงกับชุดเดิมของ Kit:
  `Idle ← Idle`, `Run ← Run`, `Flip ← Roll`, `Jump ← ท่ากระโดดที่สร้างจากเฟรมของ Run + Roll` และเพิ่ม `Hurt ← HitRecieve`, `Death ← Death`, `Victory ← Wave`
- **ระบบใหม่:** ชีวิต/หัวใจ, รับดาเมจ + กระเด็น + อมตะชั่วคราว, Checkpoint, ประตูล็อกจนกว่าจะเก็บเหรียญครบ, เปลี่ยนด่าน, Game Over, Pause, หน้าเมนู, หน้าจบเกม (สรุปเหรียญ/เวลา)
- **กับดัก:** `SpikeTrap`, `Spinner`, `MovingPlatform`, `FallingPlatform` (ปรับขนาด/ความเร็วได้ใน Inspector)
- **ฉาก:** ใช้ *Ultimate Stylized Nature Pack* (Quaternius) ผ่าน `NatureProp` (เลือก mesh ทีละชิ้นจากไฟล์ .glb) และ `Platform` ที่ปรับขนาด/สไตล์ได้ใน Inspector
- **ขนาดไฟล์:** ลดขนาด texture ของ Nature Pack เหลือไม่เกิน 512px และตัด normal map ออก (ไฟล์เกม .pck ~8 MB)
- **Renderer:** ใช้ *Compatibility* เพื่อให้รันบนเว็บได้

## โครงสร้างโปรเจกต์
```
Scenes/
  UI/MainMenu.tscn      ← ฉากเริ่มต้น
  UI/Victory.tscn, UI/HUD.tscn
  Levels/Level1.tscn, Levels/Level2.tscn
  player.tscn, Coin.tscn, Door.tscn, Checkpoint.tscn, Platform.tscn, NatureProp.tscn
  Traps/ SpikeTrap, Spinner, MovingPlatform, FallingPlatform
Scripts/                ← GDScript ทั้งหมด (GameManager เป็น Autoload)
Assets/                 ← โมเดล เสียง ฟอนต์ (Kanit) และ UI
```

## Export เป็น Web และขึ้น GitHub Pages
1. Godot → Editor → Manage Export Templates → ดาวน์โหลด templates 4.7.2
2. Project → Export → เลือก preset **Web** → Export Project → ตั้งชื่อไฟล์ `index.html`
3. สร้าง repo บน GitHub แล้วอัปโหลดไฟล์ทั้งหมดในโฟลเดอร์ที่ export (index.html, index.js, index.wasm, index.pck ฯลฯ)
4. Settings → Pages → Source: *Deploy from a branch* → เลือก `main` / root → Save
5. รอ 1–2 นาที จะได้ลิงก์ `https://<username>.github.io/<repo>/`

> preset Web ตั้งค่า *Thread Support = ปิด* ไว้แล้ว จึงเล่นบน GitHub Pages ได้โดยไม่ต้องตั้ง header พิเศษ

## เครดิต
- 3D Platformer Starter Kit — SD Studios (MIT)
- Adventurer — Quaternius (poly.pizza, CC0)
- Ultimate Stylized Nature Pack — Quaternius (poly.pizza, CC0)
- ฟอนต์ Kanit — Cadson Demak (SIL Open Font License)
