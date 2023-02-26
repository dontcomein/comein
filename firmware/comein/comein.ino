// #include <LiquidCrystal_I2C.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <esp_bt_device.h>
// #include <WiFi.h>

#define DEVICE_NAME "COMEIN_ESP32"

#define SEND "f2f9a4de-ef95-4fe1-9c2e-ab5ef6f0d6e9"
#define SEND_RGB "e376bd46-0d9a-44ab-bb71-c262d06f60c7"
#define SEND_STATUS "5c409aab-50d4-42c2-bf57-430916e5eaf4"

#define RECV "1450dbb0-e48c-4495-ae90-5ff53327ede4"
#define RECV_RGB "ec693074-43fe-489d-b63b-94456f83beb5"
#define RECV_STATUS "9393c756-78ea-4629-a53e-52fb10f9a63f"

// pin 37 -> gpio 23
static const uint8_t redPin = 23;
// pin 31 -> gpio 19
static const uint8_t greenPin = 21;
// pin 30 -> gpio 18
static const uint8_t bluePin = 22;

// LCD I2C pins:
//  i2c SCL -> GPIO 22 -> pin 36
//  i2c SDA -> GPIO 21 -> pin ?
// address 0x27

// long timer_start = 0;
// long timer_end = 1;

static BLEServer *btServer;
static struct {
  long duration = 0, timer_end = 0;
  int red = 0, green = 0, blue = 0;
  bool activated = false;
  bool blinker = true;
} led_state;

void writeRGB(int r, int g, int b) {
  ledcWrite(1, r);
  ledcWrite(2, g);
  ledcWrite(3, b);
}

/**

Todo
- pairing/connnections between multiple phones
**/

class ConnectionServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      BLEDevice::startAdvertising();
      Serial.printf("A new device connected [%d connection(s)]\n", btServer->getConnectedCount() + 1);
      led_state.activated = true;
      writeRGB(0, 0, 0);
    };

    void onDisconnect(BLEServer* pServer) {
      Serial.printf("A device disconnected [%d connection(s)]\n", btServer->getConnectedCount() - 1);
    }
};

class WritePriority: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String str = String(pCharacteristic->getValue().c_str());
      Serial.print("Received priority:");
      Serial.println(str);
      pCharacteristic->setValue(str.c_str());

      int c1 = str.indexOf(','), c2 = -1, c3 = -1;
      if (c1 != -1) {
        c2 = str.indexOf(',', c1 + 1);
      }
      if (c2 != -1) {
        c3 = str.indexOf(',', c2 + 1);
      }
      if (c3 != -1) {
        led_state.red = str.substring(0, c1).toInt();
        led_state.green = str.substring(c1 + 1, c2).toInt();
        led_state.blue = str.substring(c2 + 1, c3).toInt();
        led_state.duration = 1000L * str.substring(c3 + 1).toInt();
        led_state.timer_end = led_state.duration + millis();
        Serial.printf("red: %d, green: %d, blue: %d, duration: %d ms\n",
            led_state.red, led_state.green, led_state.blue, led_state.duration);
      } else {
        Serial.printf("Parse failure for charactertic: \"%s\"\n", str.c_str());
      }
    }
};

void setup() {
  Serial.begin(115200);

  ledcAttachPin(redPin, 1);
  ledcAttachPin(greenPin, 2);
  ledcAttachPin(bluePin, 3);

  // Initialize channels
  // channels 0-15, resolution 1-16 bits, freq limits depend on resolution
  // ledcSetup(uint8_t channel, uint32_t freq, uint8_t resolution_bits);
  ledcSetup(1, 12000, 8); // 12 kHz PWM, 8-bit resolution
  ledcSetup(2, 12000, 8);
  ledcSetup(3, 12000, 8);

  // writeRGB(255, 255, 255);

  BLEDevice::init(DEVICE_NAME);
  btServer = BLEDevice::createServer();
  btServer->setCallbacks(new ConnectionServerCallbacks());

  BLEService *recvService = btServer->createService(RECV);
  uint32_t cwrite = BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE;

  BLECharacteristic *recvPriority = recvService->createCharacteristic(RECV_RGB, cwrite);
  recvPriority->setCallbacks(new WritePriority());

  recvService->start();

  BLEService *sendService = btServer->createService(SEND);
  uint32_t cnotify = BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE  |
                     BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_INDICATE;

  // BLECharacteristic *publishPriority;
  // publishPriority = sendService->createCharacteristic(SEND_RGB, cnotify);
  // publishPriority->addDescriptor(new BLE2902());
  // publishPriority->setValue("0,0,0,0");

  sendService->start();

  BLEAdvertising *pAdvertising = btServer->getAdvertising();
  // fixes iPhone connection issues
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  pAdvertising->start();

  const uint8_t* bt_addr = esp_bt_dev_get_address();
  Serial.println("Device Name: " DEVICE_NAME);
  Serial.printf("MAC Address: %02X:%02X:%02X:%02X:%02X:%02X\n",
    bt_addr[0], bt_addr[1], bt_addr[2], bt_addr[3], bt_addr[4], bt_addr[5]);
}

void loop() {
  long now = millis();

  if (!led_state.activated) {
    int rgb = led_state.blinker ? 25 : 0;
    led_state.blinker = !led_state.blinker;
    writeRGB(rgb, rgb, rgb);
    delay(500);
  } else if (now <= led_state.timer_end) {
    long r = led_state.red, g = led_state.green, b = led_state.blue;
    if (led_state.duration <= 0) {
    } else {
      r = (r * (led_state.timer_end - now)) / led_state.duration;
      g = (g * (led_state.timer_end - now)) / led_state.duration;
      b = (b * (led_state.timer_end - now)) / led_state.duration;
    }
    writeRGB(constrain(r, 0, 255), constrain(g, 0, 255), constrain(b, 0, 255));
    delay(100);
  }
  
}