Jul 11, [2021](/blog/2021/)
# สร้างเว็บไซต์จาก Markdown ด้วย `ssg`

> Note: ผมใช้ macOS กับ Arch Linux เป็นหลัก แล้วก็ใช้เซิฟเวอร์ OpenBSD ครับ 

สวัสดีครับเพื่อนๆ วันนี้ผมจะมาสอนสร้างไฟล์ HTML จากไฟล์ Markdown สำหรับเว็บง่ายๆ (static site) เช่น Artnoi.com ครับ เหมาะกับคนที่อยากได้บล็อกแบบเรียบง่ายมาก และที่สำคัญมันเบาสมองมากเพราะเพื่อนๆแค่เขียนบทความในภาษา Markdown ซึ่งมันง่ายม้ากกกครับ

หลังจากเขียนบทความเสร็จ ไฟล์ Markdown ที่เพื่อนๆเขียน สามารถถูกแปลงไปเป็น HTML ได้ง่ายๆ ด้วย `ssg` (`ssg6`) ครับ

ในบทความนี้จะสอนแค่วิธีสร้างไฟล์ HTML จาก Markdown แต่ไม่รวมไปถึงการเสริฟเว็บด้วย webserver ต่างๆนะครับ อ้อละก็ เพื่อนๆอย่าลืม mix and match ไฟล์ `_header.html` และ `_footer.html` ของเพื่อนๆ กับ CSS สวยๆซักอันนะครับ!

## Requirements
สคริปต์ที่เราจะใช้คือ `ssg6` ซึ่งเป็น shell script ตัวหนึ่งครับ เราจึงจำเป็นต้องมี Unix shell ครับ จะเป็น `sh(1)`, `bash(1)`, `dash(1)`, หรือ `ksh(1)` ก็ได้ครับ ผมจำได้ว่าเคยรัน ssg6 ด้วย `sh(1)`, `ksh(1)`, `bash(1)` แล้วมันได้หมดเลย ซึ่งก็ควรเป็นงั้นเพราะสคริปต์นี้ POSIX สุดๆครับ เรียกได้ว่า POSIX-only เลยดีกว่า

เพราะเราต้องการใช้ Unix shell ระบบปฏิบัติการของเราควรเป็น Unix-like เช่น macOS หริอ Linux distro ต่างๆครับ

> เพื่อนๆที่ใช้ Windows ลองติดตั้ง `bash(1)` และ `perl(5)` ดูครับ หรือจะใช้ Windows Subsystem for Linux (WSL) ดูก็ได้ครับแต่ผมว่ามันจะ overkill ไปหน่อย ถ้ามันไม่มีคอม Unix ให้่ใช้ก็ใช้ Linux VPS ของเพื่อนๆก็ได้ครับ

นอกจาก shell แล้ว เรายังต้องการ Perl ซึ่งหากคุณใช้ระบบปฏิบัติการแบบ Unix-like ก็น่าจะมีติดเครื่องกันอยู่แล้วครับ

## ดาวน์โหลด `ssg6` และ `Markdown.pl`

สำหรับระบบปฏิบัติการแบบ Unix-like เราสามารถทำการติดตั้งและตั้งค่า permission ได้ด้วยคำสั่งพวกนี้ครับ:

    $ mkdir -p bin
    $ curl -s https://rgz.ee/bin/ssg6 > bin/ssg6
    $ curl -s https://rgz.ee/bin/Markdown.pl > bin/Markdown.pl
    $ chmod +x bin/ssg6 bin/Markdown.pl

> เพื่อนๆที่ใช้ Windows สามารถดาวน์โหลด `ssg6` ได้จากเว็บผู้เขียน [rgz.ee](https://rgz.ee/bin/ssg6) ได้เลยครับ เราสามารถก็อปปี้เนื้อหาไฟล์มาวางไว้บนไฟล์บนเครื่องเราได้ครับ

`ssg6` ใช้ `Markdown.pl` หรือ `lowdown` เพื่อแปลงไฟล์ Markdown ไปเป็น HTML เพื่อนๆสามารถโหลดไฟล์ `Markdown.pl` (Perl) จาก [rgz.ee](https://rgz.ee/bin/Markdown.pl) ได้ครับ แล้วเซฟด้วยวิธีแบบเดียวกันกับ `ssg` ครับ

หลังจากติดตั้ง `ssg` และ `Markdown.pl` เรียบร้อยแล้ว เราสามารถลงมือเขียนเว็บของเราในภาษา Markdown ได้เลยครับ

## `ssg6` ทำอะไรบ้าง
- แปลง Markdown เป็น HTML

- ประกอบ `_header.html` และ `_footer.html` เพื่อสร้างส่วนหัวและท้ายของหน้าเพจเรา

- สร้าง `robot.txt` และ `sitemap.xml` สำหรับ SEO

## ภาษา Markdown แบบเบสิค
ก่อนจะไปต่อผมอยากให้เพื่อนๆเรียนรู้ หรือทบทวนภาษา Markdown กันก่อนครับ [อ่านลิงค์นี้](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)แล้วลอง[ทบทวนที่ลิงค์นี้](https://stackedit.io/app)ดูนะครับ โดยเฉพาะคนที่ไม่แม่น Markdown

## เริ่มต้นเขียนเว็บไซต์
ผมแนะนำให้เพื่อนๆ สร้างสองโฟลเดอร์ขึ้นมา คือโฟลเดอร์สำหรับ Markdown และ HTML ครับ โดยในตัวอย่างนี้ ผมจะตั้งชื่อทั้งสองโฟลเดอร์ว่า `md-mysite` และ `html-mysite` ตามลำดับครับ

> Note: ไฟล์ `md-mysite/myfile.md` จะถูก ssg6 แปลงไปเป็นไฟล์ `html-mysite/myfile.html` ครับ

เพื่อนๆเริ่มเขียน `index.md` ในโฟลเดอร์ `md-mysite` ก่อน หลังจากเขียน Markdown เสร็จ ให้ใช้คำสั่งด้านล่าง เพื่อแปลง Markdown ไปเป็น HTML ด้วย ssg6 ครับ:

    $ ssg6 "md-mysite" "html-mysite" "My site" "https://mysite.com"

> syntax ของ ssg6 คือ `ssg6 src dst title base_url` ครับ src คือโฟลเดอร์ source ส่วน dst คือโฟลเดอร์เป้าหมาย (ไฟล์ HTML ของเรานั่นเองครับ)

อย่าลืมเปลี่ยนโดเมนเนม ให้ตรงกับเว็บไซต์ของเรานะครับ

เท่านี้เราก็มีไฟล์เว็บไซต์ พร้อมเสริฟด้วย webserver แล้วครับ

## ไฟล์ `_header.html` และ `_footer.html`
`ssg6` จะรวมทั้งสองไฟล์ (`_header.html`, `_footer.html`) เข้าไปในไฟล์ HTML ของเราครับ โดยมันจะ prepend `_header.html` และ append `_footer.html)` และอีกเงื่อนไขคือทั้งสองไฟล์นี้ต้องอยู่ในโฟลเดอร์ root ที่เราเก็บเหล่าไฟล์ Markdown ไว้ครับ

หลังรวมร่างแล้ว ไฟล์ HTML สุดท้าย จะมีส่วนประกอบดังนี้ครับ

    _header.html (จาก md-mysite/_header.html)
    ++++++++++++
    index.html (จาก md-mysite/index.md)
    ++++++++++++
    _footer.html (จาก md-mysite/_footer.html)

หากดูภาพแล้วยังไม่เข้าใจ ลองดูตัวอย่างไฟล์ข้างล่างครับ

ตัวอย่าง `_header.html`:

    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="artnoi, Prem Phansuriyanon">
        <meta name="author" content="@artnoi">
        <meta charset="UTF-8">
        <link rel="stylesheet" type="text/css" href="/style.css">
        <title>Artnoi.com</title>
    </head>
    <body>
        <h1>Artnoi.com!</h1>
        <hr>

ตัวอย่างไฟล์ `index.md`

    # Hello, world!
    Today is a great day, isn't it boys?

ตัวอย่าง `_footer.html`

    </body>
    <hr>
    <p><a href="#top">Back to top</a></p>
    <hr>
    <footer>
        <p>Copyright (c) 2019 - 2021 Prem Phansuriyanon</p>
        <p>Verbatim copying and redistribution of this entire page are permitted provided this notice is preserved</p>
    </footer>
    </html>

ตัวอย่าง `index.html` ที่ `ssg6` สร้างขึ้น

    <!DOCTYPE html>
    <html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="artnoi, Prem Phansuriyanon">
        <meta name="author" content="@artnoi">
        <meta charset="UTF-8">
        <link rel="stylesheet" type="text/css" href="/style.css">
        <title>Artnoi.com</title>
    </head>
    <body>
        <h1>Artnoi.com!</h1>
        <hr>
        <h1>Hello world!</h1>
        <p>Today is a great day, isn't it boys?</p>
    </body>
    <hr>
    <p><a href="#top">Back to top</a></p>
    <hr>
    <footer>
        <p>Copyright (c) 2019 - 2021 Prem Phansuriyanon</p>
        <p>Verbatim copying and redistribution of this entire page are permitted provided this notice is preserved</p>
    </footer>
    </html>

เท่านี้เว็บที่เรียบง่ายของเราก็เสร็จแล้วครับเพื่อนๆ เราสามารถก็อปโฟลเดอร์ `html-mysite` ของเราไปไว้บนเซิฟเวอร์ ที่มีซอฟต์แวร์ webserver แล้วเสริฟเว็บได้ทันทีครับ

หากเพื่อนๆมีข้อสงสัย หรือผมเขียนแย่จนอ่านไม่รู้เรื่อง เพื่อนๆสามารถตามไปอ่านที่ [rgz.ee](https://rgz.ee/ssg.html) ต้นฉบับ `ssg` ได้ครับ
