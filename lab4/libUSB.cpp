#include <iostream>
#include <libusb-1.0/libusb.h>
#include <stdio.h>

using namespace std;

void printdev(libusb_device *dev);

int main()
{
    libusb_device **devs;       // указатель на указатель на устройство
    libusb_context *ctx = NULL; // контекст сессии libusb
    int r;                      // для возвращаемых значений
    r = libusb_init(&ctx);
    if (r < 0)
    {
        cout << "Initializing failed with code: " << r << endl;
        return 1;
    }
    // задать уровень подробности отладочных сообщений
    libusb_set_debug(ctx, 3);

    // получить список всех найденных USB- устройств
    size_t cnt = libusb_get_device_list(ctx, &devs);
    if (cnt < 0)
    {
        cout << "Failed to get device list " << r << endl;
        return 1;
    }

    cout << "Number of found devices: " << cnt << endl;
    for (size_t i = 0; i < cnt; i++)
    {                      // цикл перебора всех устройств
        printdev(devs[i]); // печать параметров устройства
    }

    // освободить память, выделенную функцией получения списка устройств
    libusb_free_device_list(devs, 1);
    libusb_exit(ctx); // завершить работу с библиотекой libusb,
    // закрыть сессию работы с libusb
    return 0;
}
void printdev(libusb_device *dev)
{
    libusb_device_descriptor desc; // дескриптор устройства
    int r = libusb_get_device_descriptor(dev, &desc);
    if (r < 0)
    {
        cout << "Failed to get device descriptor " << r << endl;
        return;
    }

    libusb_device_handle *dh;
    unsigned char data[1000] = {0};
    r = libusb_open(dev, &dh);
    if (r < 0)
    {
        cout << "Failed to open device " << endl
             << endl;
        return;
    }

    cout << "* Number of possible configurations: " << (int)desc.bNumConfigurations << endl;
    cout << "| * Device class: " << (int)desc.bDeviceClass << endl;

    r = libusb_get_string_descriptor_ascii(dh, desc.iManufacturer, data, 1000);
    cout << "| | * Vendor ID: " << (int)desc.idVendor << " " << data << endl;

    r = libusb_get_string_descriptor_ascii(dh, desc.iProduct, data, 1000);
    cout << "| | | * Product ID: " << (int)desc.idProduct << " " << data << endl;

    if (desc.iSerialNumber)
    {
        r = libusb_get_string_descriptor_ascii(dh, desc.iSerialNumber, data, 1000);
        cout << "| | | | * Serial Number of device: " << data << endl;
    }
    else
    {
        cout << "| | | | * Failed to get Serial Number of device" << endl;
    }

    libusb_close(dh);

    cout << endl
         << endl
         << endl;
}
