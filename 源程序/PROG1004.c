;PROG1004
#include <ntddk.h>
/*
 * IO_Bitmap��һ����СΪ8 192���ֽ�����. ���ֵȫ������Ϊ0.
 * ����ֽ�����Ĵ�СΪ8 192�ֽ�, һ����8 192*8=65 536��������λ.
 * ����, ������ֽ������������ΪI/O���λͼ, ������IOPL=3��
 * Ӧ�ó����д���е�I/O�˿�. I/O�˿ڵķ�Χ��0~65 535. ���I/O
 * ���λͼ�е�ĳ��������λΪ1, ���ʾ�������д��Ӧ�Ķ˿�.
 */
UCHAR IO_Bitmap[8192];
/*
 * ������Windows�ں�API. ������API����������I/Oλͼ.
 * 
 * Ke386IoSetAccessProcess()����Ӧ�ó������I/O�˿�.
 * Ke386IoSetAccessMap()����һ���ֽ����鵽TSS��I/Oλͼ��.
 */
void Ke386IoSetAccessProcess(PEPROCESS, int);
void Ke386SetIoAccessMap(int, UCHAR *);
/*
 * GiveIO()����Ke386IoSetAccessProcess()��Ke386SetIoAccessMap()
 * ����I/Oλͼ
 */
void GiveIO(void)
{
        RtlZeroMemory(IO_Bitmap, sizeof(IO_Bitmap));
        Ke386IoSetAccessProcess(PsGetCurrentProcess(), 1);
        Ke386SetIoAccessMap(1, IO_Bitmap);
}
/*
 * ���û��������CreateFile��"\\.\giveio"ʱ, �����ں�ģʽ��ִ��
 * �˺���. ��ʱ, CPL=0, �����ܹ�����Ke386IoSetAccessProcess()��
 * Ke386SetIoAccessMap(). ��CPL=3ʱ����ִ����Щ����.
 */
NTSTATUS GiveioCreate(
    IN  PDEVICE_OBJECT  DeviceObject,
    IN  PIRP            Irp
    )
{
        GiveIO();
        Irp��IoStatus.Information = 0;
        Irp��IoStatus.Status = STATUS_SUCCESS;
        IoCompleteRequest(Irp, IO_NO_INCREMENT);
        return STATUS_SUCCESS;
}
/*
 * ж��giveio.sysʱ, GiveioUnload()������
 */
VOID GiveioUnload(
    IN  PDRIVER_OBJECT  DriverObject
    )
{
        UNICODE_STRING uniDOSString;
        WCHAR DOSNameBuffer[] = L"\\DosDevices\\giveio";
        RtlInitUnicodeString(&uniDOSString, DOSNameBuffer);
        IoDeleteSymbolicLink (&uniDOSString);
        IoDeleteDevice(DriverObject��DeviceObject);
}
/*
 * giveio.sys��������ĳ�ʼ������.
 * װ��giveio.sysʱ, DriverEntry()������. 
 * ��������\\.\giveio�豸.
 * ���������˸���������Ĺ��ܱ�. ��:
 *  (1) �ڴ�"\\.\giveio"ʱ, ִ��GiveioCreate()
 *  (2) ��ж��giveio.sysʱ, ִ��GiveioUnload()
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
        DriverObject��MajorFunction[IRP_MJ_CREATE] = GiveioCreate;
        DriverObject��DriverUnload = GiveioUnload;
        return STATUS_SUCCESS;
}