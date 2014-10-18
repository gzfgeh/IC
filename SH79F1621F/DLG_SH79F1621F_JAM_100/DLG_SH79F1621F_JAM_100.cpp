// DLG_SH79F1621F_JAM_100.cpp : Defines the initialization routines for the DLL.
//

#include "stdafx.h"
#include <afxpropertypage.h>
#include "DLGSH79F1621F.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


extern "C"
__declspec(dllexport) CMFCPropertyPage * GetPropertyPage(struct chip_info_c * ChipInfo, unsigned char *RegisterBuff, unsigned long BuffLen, unsigned long *pDataLen)
{
    CMFCPropertyPage *page = NULL;
    page = new CDLGSH79F1621F(ChipInfo, RegisterBuff, BuffLen, pDataLen);

    return page;
}

