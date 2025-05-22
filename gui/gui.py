import sys
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.gridlayout import GridLayout
from kivy.core.window import Window
from kivy.metrics import dp
from kivy.graphics import Color, RoundedRectangle
from kivy.uix.anchorlayout import AnchorLayout

Window.size = (1200, 675)
Window.clearcolor = (0.14, 0.14, 0.13, 1)

# --- Mock Serial (same as before) ---
class MockSerial:
    def __init__(self, port, baudrate, timeout=None):
        print(f"MockSerial initialized on port {port} at {baudrate} baud")
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout

    def write(self, data):
        print(f"MockSerial write: {data}")

    def readline(self):
        return b'Mock data\n'

    def close(self):
        print("MockSerial closed")

try:
    import serial
    serial_port = serial.Serial('COM3', 9600, timeout=0.1)
except Exception as e:
    print(f"Using MockSerial: {e}")
    serial_port = MockSerial('COM3', 9600, timeout=0.1)


class RoundedButton(Button):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.background_normal = ''
        self.background_down = ''
        self.background_color = (0, 0, 0, 0)
        self.color = (0.1, 0.1, 0.1, 1)
        self.font_size = '24sp'
        self.size_hint = (1, 1)

        with self.canvas.before:
            self.bg_color = Color(1.0, 0.8, 0.15, 1)
            self.bg_rect = RoundedRectangle(pos=self.pos, size=self.size, radius=[15])
        self.bind(pos=self.update_graphics, size=self.update_graphics)

    def update_graphics(self, *args):
        self.bg_rect.pos = self.pos
        self.bg_rect.size = self.size

class FitToLiftApp(App):
    def build(self):
        root = BoxLayout(orientation='vertical', padding=dp(20), spacing=dp(10))

        # Title
        root.add_widget(Label(
            text="Fit To Lift",
            font_size='68sp',
            font_name="Roboto",
            bold=True,
            color=(1, 1, 1, 1),
            size_hint=(1, 0.15)
        ))

        # Instructions
        root.add_widget(Label(
            text="Please enter your height, in inches:",
            font_size='22sp',
            font_name="Roboto",
            color=(1, 1, 1, 0.7),
            size_hint=(1, 0.1)
        ))

        # Input
        input_container = AnchorLayout(
            anchor_x='center',
            size_hint=(1, 0.15)
        )

        self.input_box = TextInput(
            multiline=False,
            font_size='56sp',
            size_hint=(None, None),
            width=dp(400),
            halign="center",
            background_color=(1, 1, 1, 1),
            foreground_color=(0, 0, 0, 1),
            cursor_color=(0.2, 0.6, 0.86, 1),
            write_tab=False,
            padding_y=(dp(12), dp(12)),
            input_filter='int',
        )

        input_container.add_widget(self.input_box)
        root.add_widget(input_container)

        # Number pad
        grid = GridLayout(cols=3, spacing=dp(14), size_hint=(1, 0.45))

        buttons = [
            ('1', self.add_number), ('2', self.add_number), ('3', self.add_number),
            ('4', self.add_number), ('5', self.add_number), ('6', self.add_number),
            ('7', self.add_number), ('8', self.add_number), ('9', self.add_number),
            ('Clear', self.clear_input), ('0', self.add_number), ('Delete', self.delete_last)
        ]

        for label, callback in buttons:
            btn = RoundedButton(text=label)
            btn.bind(on_release=lambda btn, c=callback: c(btn.text))
            grid.add_widget(btn)

        root.add_widget(grid)

        # Footer
        watermark = Label(
            text="Designed & Manufactured by Rapid Acceleration",
            font_size='16sp',
            color=(1, 1, 1, 0.4),
            size_hint=(1, 0.05),
            halign='left',
            valign='bottom'
        )
        watermark.bind(size=watermark.setter('text_size'))
        root.add_widget(watermark)

        return root

    def add_number(self, number):
        if len(self.input_box.text) < 3:
            self.input_box.text += number
            serial_port.write(number.encode())


    def clear_input(self, _):
        self.input_box.text = ''
        serial_port.write(b'C')

    def delete_last(self, _):
        self.input_box.text = self.input_box.text[:-1]
        serial_port.write(b'D')


if __name__ == "__main__":
    FitToLiftApp().run()
    serial_port.close()
