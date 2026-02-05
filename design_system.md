## Saku App Design System

### **Warna Utama (Color Palette)**

| Nama               | Hex Code              | Penggunaan                               |
| ------------------ | --------------------- | ---------------------------------------- |
| **Primary Dark**   | ```<br>#111111<br>``` | Teks utama, button selected, icon aktif  |
| **Secondary Gray** | ```<br>#1F2937<br>``` | Background nav bar gelap, icon secondary |
| **Light Gray**     | ```<br>#F3F4F6<br>``` | Background tab selector, chips, cards    |
| **Muted Gray**     | ```<br>#9CA3AF<br>``` | Teks tidak aktif, icon tidak aktif       |
| **Dark Muted**     | ```<br>#6B7280<br>``` | Teks secondary/subtitle                  |
| **Background**     | ```<br>#FAFAFA<br>``` | Background page utama                    |
| **White**          | ```<br>#FFFFFF<br>``` | Card background, selected tab indicator  |
|                    |                       |                                          |

### **Semantic Colors**

|Nama|Hex Code|Penggunaan|
|---|---|---|
|**Semantic Red**|```<br>#EF4444<br>```|Pengeluaran, expense|
|**Semantic Green**|```<br>#10B981<br>```|Pemasukan, income|

### **Styling Elements**

**Border Radius:**

- Pills/Chips: 
    
    ```
    30px
    ```
    
     - 
    
    ```
    32px
    ```
    
- Cards: 
    
    ```
    16px
    ```
    
     - 
    
    ```
    20px
    ```
    
- Buttons: 
    
    ```
    20px
    ```
    
     - 
    
    ```
    24px
    ```
    
- Small elements: 
    
    ```
    8px
    ```
    
     - 
    
    ```
    12px
    ```
    

**Shadows:**

- Cards: 
    
    ```
    BoxShadow(color: black 5%, blur: 4-8, offset: 0,2)
    ```
    
- Navigation: 
    
    ```
    BoxShadow(color: black 8%, blur: 20, offset: 0,4)
    ```
    

**Animations:**

- Duration: 
    
    ```
    200ms
    ```
    
     - 
    
    ```
    300ms
    ```
    
- Curve: 
    
    ```
    Curves.easeInOut
    ```
    

### **Component Patterns**

**Tab Selector:**

- Container: Light gray background, rounded pill
- Selected: White with shadow
- Unselected: Transparent with muted gray text

**Bottom Navigation:**

- Dark bar (
    
    ```
    #1F2937
    ```
    
    ) dengan opacity 85%
- White icons, curved animation

**Buttons/Links:**

- Menggunakan warna hitam (
    
    ```
    #111111
    ```
    
    ) bukan biru
- Font weight: 
    
    ```
    w600
    ```