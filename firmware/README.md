# Comein firmware


BLE Interface

There are two BLE services defined, the sending service & the receiving service.

Each of these services have two characteristics. In the sending service, these characteristics are read from the esp32 (which publishes them), and on the receiving service, these characteristics are written to the esp32 from a client.

The way BLE works, each of these services/characteristics has an associated UUID. This is required for a client to communicate with these characteristics. Here is a table of Service/characteristic to UUID.


| Characteristic/Service | UUID |
| -----------------------| -----|
| Send Service | f2f9a4de-ef95-4fe1-9c2e-ab5ef6f0d6e9 |
| RGB characteristic (Send) | e376bd46-0d9a-44ab-bb71-c262d06f60c7 |
| Status characteristic (Send) | 5c409aab-50d4-42c2-bf57-430916e5eaf4 |
| Receive Service | 1450dbb0-e48c-4495-ae90-5ff53327ede4 |
| RGB characteristic (Receive) | ec693074-43fe-489d-b63b-94456f83beb5 |
| Status characteristic (Receive) | 9393c756-78ea-4629-a53e-52fb10f9a63f |

Both the RGB/Status characteristic are written strings.

The status characteristic can have maximum of 16 characters (LCD length), and the RGB characteristic is in the form of `"r,g,b"`, where r,g,b are integer values between 0-255. If these constraints are not followed, the esp32 will ignore the input.


