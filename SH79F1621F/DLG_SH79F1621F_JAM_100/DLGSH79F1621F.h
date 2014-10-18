#pragma once
#include "resource.h"
#include "..\ICSettingPage\ICSettingPage.h"

// CDLGSH79F1621F dialog

class CDLGSH79F1621F : public CICSettingPage
{
	DECLARE_DYNAMIC(CDLGSH79F1621F)

public:
    CDLGSH79F1621F(struct chip_info_c * ChipInfo, unsigned char *RegisterBuff, unsigned long BuffLen, unsigned long *pDataLen, CWnd* pParent = NULL);

	virtual ~CDLGSH79F1621F();

// Dialog Data
	enum { IDD = IDD_DIALOG1 };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
    virtual BOOL ShowData(const struct chip_info_c *chip, const unsigned char *pRegbuff, unsigned long nBufferLen);
    virtual BOOL OutputData(const struct chip_info_c *chip, unsigned char *pRegBuff, unsigned long nBufferLen, unsigned long *pDataLen);
};
