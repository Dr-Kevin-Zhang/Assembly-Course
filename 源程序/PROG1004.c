;PROG1004
#include <ntddk.h>
/*
 * IO_Bitmap是一个大小为8 192的字节数组. 其初值全部设置为0.
 * 这个字节数组的大小为8 192字节, 一共有8 192*8=65 536个二进制位.
 * 所以, 将这个字节数组的内容作为I/O许可位图, 就允许IOPL=3的
 * 应用程序读写所有的I/O端口. I/O端口的范围是0~65 535. 如果I/O
 * 许可位图中的某个二进制位为1, 则表示不允许读写对应的端口.
 */
UCHAR IO_Bitmap[8192];
/*
 * 有两个Windows内核API. 这两个API可用来设置I/O位图.
 * 
 * Ke386IoSetAccessProcess()允许应用程序访问I/O端口.
 * Ke386IoSetAccessMap()复制一个字节数组到TSS的I/O位图中.
 */
void Ke386IoSetAccessProcess(PEPROCESS, int);
void Ke386SetIoAccessMap(int, UCHAR *);
/*
 * GiveIO()调用Ke386IoSetAccessProcess()和Ke386SetIoAccessMap()
 * 设置I/O位图
 */
void GiveIO(void)
{
        RtlZeroMemory(IO_Bitmap, sizeof(IO_Bitmap));
        Ke386IoSetAccessProcess(PsGetCurrentProcess(), 1);
        Ke386SetIoAccessMap(1, IO_Bitmap);
}
/*
 * 当用户程序调用CreateFile打开"\\.\giveio"时, 进入内核模式下执行
 * 此函数. 这时, CPL=0, 所以能够调用Ke386IoSetAccessProcess()和
 * Ke386SetIoAccessMap(). 在CPL=3时不能执行这些函数.
 */
NTSTATUS GiveioCreate(
    IN  PDEVICE_OBJECT  DeviceObject,
    IN  PIRP            Irp
    )
{
        GiveIO();
        Irp→IoStatus.Information = 0;
        Irp→IoStatus.Status = STATUS_SUCCESS;
        IoCompleteRequest(Irp, IO_NO_INCREMENT);
        return STATUS_SUCCESS;
}
/*
 * 卸载giveio.sys时, GiveioUnload()被调用
 */
VOID GiveioUnload(
    IN  PDRIVER_OBJECT  DriverObject
    )
{
        UNICODE_STRING uniDOSString;
        WCHAR DOSNameBuffer[] = L"\\DosDevices\\giveio";
        RtlInitUnicodeString(&uniDOSString, DOSNameBuffer);
        IoDeleteSymbolicLink (&uniDOSString);
        IoDeleteDevice(DriverObject→DeviceObject);
}
/*
 * giveio.sys驱动程序的初始化部分.
 * 装入giveio.sys时, DriverEntry()被调用. 
 * 它创建了\\.\giveio设备.
 * 并且设置了该驱动程序的功能表. 即:
 *  (1) 在打开"\\.\giveio"时, 执行GiveioCreate()
 *  (2) 在卸载giveio.sys时, 执行GiveioUnload()
 */
NTSTATUS DriverEntry(
    IN  PDRIVER_OBJECT  DriverObject,
    IN  PUNICODE_STRING RegistryPath
    )
{
        PDEVICE_OBJECT deviceObject;
        NTSTATUS status;
        WCHAR NameBuffer[] = L"\\Device\\giveio";
        WCHAR DOSNameBuffer[] = L"\\DosDevices\\giveio";
        UNICODE_STRING uniNameString, uniDOSString;
        RtlInitUnicodeString(&uniNameString, NameBuffer);
        RtlInitUnicodeString(&uniDOSString, DOSNameBuffer);
        status = IoCreateDevice(DriverObject, 0,
				&uniNameString,
				FILE_DEVICE_UNKNOWN, 0, FALSE, 
				&deviceObject);
        if(!NT_SUCCESS(status))
                return status;
        status = IoCreateSymbolicLink (&uniDOSString, &uniNameString);
        if (!NT_SUCCESS(status))
                return status;
        DriverObject→MajorFunction[IRP_MJ_CREATE] = GiveioCreate;
        DriverObject→DriverUnload = GiveioUnload;
        return STATUS_SUCCESS;
}