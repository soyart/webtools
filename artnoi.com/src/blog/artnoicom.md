September 29, [2020](/blog/2020)
Yeah I know, my site looks boring and not worth anything to write home about, but still this is my blog so I can write whatever the heck I want.
# How I design this website (See also: [how I write my blog](/blog/howblog.html))
This website is designed largely around practical factors - readability, eye comfort, friendliness to terminal-based browser, copy-pasting code, as well as minimalism (truly minimal, not like WordPress's many minimal themes). The entire process of site generation is also minimal - the entire site is first written in `markdown` plain-text files, with each `markdown` file only containing its content (like an article or a blog post) and not the header/footer part of the page. Then I write separate HTML header and footer files. Those `markdown` files and the separate header/footer files are later assembled into a complete standalone HTML files.
## Header and footer
[ssg5](/blog/howblog.html) will generate the webpages with the same header and footer. I want my header to feature navigation, website name and logo (which is now accomplished using a single ASCII art), and nothing more. The navigation should look obvious, neat, and all-lowercase to add false sense of minimalism. For footer, I wanted it to have some copyright notice written in Serif fonts just like [RMS's website](stallman.org).
## Header logo
The logo is generated using `toilet` and `smslant` (small slant) font (`$ toilet -f smslant "Artnoi"`). I'm not sure whether the font is provided by `toilet` or `figlet`. I choose the font because it's small enough not to break the pages on small screens.
## Inspiration
I got most of my site inspiration from [OpenBSD.org](https://openbsd.org) - I even wanted to use [OpenBSD's color scheme](https://www.schemecolor.com/openbsd-logo-colors.php), but switched back to my own after one of my friend said it was lame. The layout is inspired by [this website](https://niklasfasching.de/posts/just-enough-css). I used their CSS and modified it (i.e. minimalize it) to better suit my use. All-text and static site mentality is inspired by [Kiss Linux website](https://k1ss.org) and many other geek blogs.
## Decisions
The website would have all text content, without any Javascripts or PHP. As a result my website should look good and easily usable on both GUI browers and terminal-based browser. If illustration is needed, ASCII art will be used.
### Fonts
To focus on readability, I use non-specific *Sans* type font (which will vary in different browsers), as well as 1.5 font size for HTML paragraphs. The code font is also just non-specific monospace. I don't and won't load external resources for my CSS style.
### Colors
My pages currently only display 4 colors: the dark background color (#2f2f2f), whiteish one for paragraph text (#c2c5cc), blueish one for links (#8fe3fd), and the orangeish one for accent and paragraph headers (#ffaf7a).
#### Background (**#2f2f2f**)
I wanted *dark-mode* website, so I actually started choosing color with background. OpenBSD's dark-mode pages also have nice dark background, but I find my current color to look better with other colors I have settled with.
#### Paragraph (**#c2c5cc**)
I then tried to find a suitable paragraph color that will be both readable and comfortable at the same time. This one has just enough contrast between the background and other colors.
#### Links (**#8fe3fd**)
The blueish color (#8fd3fe) is chosen because of my familiarity with blue links, and also because I think it looks intuitive to visitors.
#### Artnoi Orange (**#ffaf7a**)
I could have been okay with only 3 colors, but the website looked really monotonous, despite having 3 colors already. This is because the prior 3 colors are *staple* in most simple websites: dark background, white text, and blue links. So I add this orange color to kind of give my website a little bit of identity.
## Media support
Download or view links will be used to provide pictures or other non-text content. In-line images may be reconsidered, but now, no.
