#PHILLIPS PCF8574 I2C LCD44780 ESP8266 NodeMCU Module
####Quick start:
```lua
lcd = require("lcd_pcf8574")
-- use GPIO pin 5 and 4 for SDA and SCL respectively,
-- and tell the library the display is 16x2 characters big (this is by default, so you can omit them).
lcd.begin(1, 2, 16, 2)
lcd.print("Hello, world!")
function notice() lcd.scroll(1, "This is the scrolling line. NodeMCU heap:" .. node.heap(), 1, 150, notice) end; notice()
```

####Details:
I use 4-bit connection with display, wiring as follow:

P7 | P6 | P5 | P4 | P3 | P2 | P1 | P0
---|----|----|----|----|----|----|---
D7 | D6 | D5 | D4 | (BL) | EN | RW | RS

####Available methods:
#####.begin(pinSDA, pinSCL, cols, rows, address)
Initalize display first

Name | Description | Default value
---- | ----------- | -------------
_pinSDA_ | SDA pin in NodeMCU index | __required__
_pinSCL_ | SCL pin in NodeMCU index | __required__
_cols_ | number of columns | 16
_rows_ | number of rows | 2
_address_ | I2C address of PCF8574, without RW bit | 0x27 (010 0111)

#####.write(character)
Writes one character to LCD

Name | Description | Default value
---- | ----------- | -------------
_character_ | character to write | __required__

#####.print(string)
Writes a string to LCD

Name | Description | Default value
---- | ----------- | -------------
_string_ | string to write | __required__

#####.scroll(row, string, timer, delay, callback)
Writes a string to LCD and scrolls it right to left, then calls optional callback.

Name | Description | Default value
---- | ----------- | -------------
_row_ | row to write on | __required__
_string_ | string to write | __required__
_timer_ | timer ID (0-6) | __required__
_delay_ | delay between shifting | __required__
_callback_ | function to call, after one scroll is over | another scroll begins

#####.setCursor(col, row)
Position cursor to selected column and row

Name | Description | Default value
---- | ----------- | -------------
_col_ | column to place cursor to, starting with 0 | __required__
_row_ | row to place cursor to, starting with 0 | __required__

#####.setBacklight(on)
Turns backlight on and off, if supported

Name | Description | Default value
---- | ----------- | -------------
_on_ | 0 or 1 to turn off and on respectively | 1

#####.clear()
Clear LCD
