// DLGSH79F1621F.cpp : implementation file
//

#include "stdafx.h"
#include "DLGSH79F1621F.h"
#include "afxdialogex.h"
#include "..\ICSettingPage\ICSettingPage.h"

// CDLGSH79F1621F dialog

IMPLEMENT_DYNAMIC(CDLGSH79F1621F, CICSettingPage)

CDLGSH79F1621F::CDLGSH79F1621F(struct chip_info_c * ChipInfo, unsigned char *RegisterBuff, unsigned long BuffLen, unsigned long *pDataLen, CWnd* pParent /*=NULL*/)
: CICSettingPage(CDLGSH79F1621F::IDD, ChipInfo, RegisterBuff, BuffLen, pDataLen)
{

}

CDLGSH79F1621F::~CDLGSH79F1621F()
{
}

void CDLGSH79F1621F::DoDataExchange(CDataExchange* pDX)
{
	CPropertyPage::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CDLGSH79F1621F, CICSettingPage)
END_MESSAGE_MAP()


// CDLGSH79F1621F message handlers
BOOL CDLGSH79F1621F::ShowData(const struct chip_info_c *chip, const unsigned char *pRegbuff, unsigned long nBufferLen)
{
    UCHAR ucSecurityFlag[8];
    memcpy(ucSecurityFlag, pRegbuff, 8);
    UCHAR flag = 1;

    ucSecurityFlag[0] = ucSecurityFlag[0] >> 3;
    switch (ucSecurityFlag[0] & 0x3)
    {
    case 0:
        CheckRadioButton(IDC_RADIO4_LEST, IDC_RADIO4_SEST, IDC_RADIO4_LEST);
        break;
    case 1:
        CheckRadioButton(IDC_RADIO4_LEST, IDC_RADIO4_SEST, IDC_RADIO4_LER);
        break;
    case 2:
        CheckRadioButton(IDC_RADIO4_LEST, IDC_RADIO4_SEST, IDC_RADIO4_SER);
        break;
    case 3:
        CheckRadioButton(IDC_RADIO4_LEST, IDC_RADIO4_SEST, IDC_RADIO4_SEST);
        break;
    default:
        break;
    }
    ucSecurityFlag[0] = ucSecurityFlag[0] >> 2;

    if ((flag & ucSecurityFlag[0]) == 1)
        CheckRadioButton(IDC_RADIO3_RST, IDC_RADIO3_IO, IDC_RADIO3_IO);
    else
        CheckRadioButton(IDC_RADIO3_RST, IDC_RADIO3_IO, IDC_RADIO3_RST);
    ucSecurityFlag[0] = ucSecurityFlag[0] >> 1;

    if ((flag & ucSecurityFlag[0]) == 1)
        CheckRadioButton(IDC_RADIO2_DIS, IDC_RADIO2_EN, IDC_RADIO2_EN);
    else
        CheckRadioButton(IDC_RADIO2_DIS, IDC_RADIO2_EN, IDC_RADIO2_DIS);
    ucSecurityFlag[0] = ucSecurityFlag[0] >> 1;


    if ((flag & ucSecurityFlag[0]) == 1)
        CheckRadioButton(IDC_RADIO1_DIS, IDC_RADIO1_EN, IDC_RADIO1_EN);
    else
        CheckRadioButton(IDC_RADIO1_DIS, IDC_RADIO1_EN, IDC_RADIO1_DIS);



    ucSecurityFlag[1] = ucSecurityFlag[1] >> 1;
    if ((flag & ucSecurityFlag[1]) == 1)
        CheckRadioButton(IDC_RADIO8_NOR, IDC_RADIO8_INV, IDC_RADIO8_INV);
    else
        CheckRadioButton(IDC_RADIO8_NOR, IDC_RADIO8_INV, IDC_RADIO8_NOR);
    ucSecurityFlag[1] = ucSecurityFlag[1] >> 2;

    if ((flag & ucSecurityFlag[1]) == 1)
        CheckRadioButton(IDC_RADIO7_INV, IDC_RADIO7_VAL, IDC_RADIO7_VAL);
    else
        CheckRadioButton(IDC_RADIO7_INV, IDC_RADIO7_VAL, IDC_RADIO7_INV);
    ucSecurityFlag[1] = ucSecurityFlag[1] >> 3;

    if ((flag & ucSecurityFlag[1]) == 1)
        CheckRadioButton(IDC_RADIO6_21V, IDC_RADIO6_43V, IDC_RADIO6_43V);
    else
        CheckRadioButton(IDC_RADIO6_21V, IDC_RADIO6_43V, IDC_RADIO6_21V);
    ucSecurityFlag[1] = ucSecurityFlag[1] >> 1;

    if ((flag & ucSecurityFlag[1]) == 1)
        CheckRadioButton(IDC_RADIO5_DIS, IDC_RADIO5_EN, IDC_RADIO5_EN);
    else
        CheckRadioButton(IDC_RADIO5_DIS, IDC_RADIO5_EN, IDC_RADIO5_DIS);


    switch (ucSecurityFlag[2] & 0xF)
    {
    case 0:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_12);
        break;
    case 3:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_12812);
        break;
    case 6:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_12802);
        break;
    case 0xa:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_3212);
        break;
    case 0xd:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_3202);
        break;
    case 0xe:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_0212);
        break;
    default:
        CheckRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212, IDC_RADIO10_12);
        break;
    }
    ucSecurityFlag[2] = ucSecurityFlag[2] >> 7;
    if ((flag & ucSecurityFlag[2]) == 1)
        CheckRadioButton(IDC_RADIO9_KEEP, IDC_RADIO9_CHA, IDC_RADIO9_CHA);
    else
        CheckRadioButton(IDC_RADIO9_KEEP, IDC_RADIO9_CHA, IDC_RADIO9_KEEP);


    if ((flag & ucSecurityFlag[3]) == 1)
        CheckRadioButton(IDC_RADIO13_CHA, IDC_RADIO13_KEEP, IDC_RADIO13_KEEP);
    else
        CheckRadioButton(IDC_RADIO13_CHA, IDC_RADIO13_KEEP, IDC_RADIO13_CHA);
    ucSecurityFlag[3] = ucSecurityFlag[3] >> 1;

    if ((flag & ucSecurityFlag[3]) == 1)
        CheckRadioButton(IDC_RADIO12_KEEP, IDC_RADIO12_CHA, IDC_RADIO12_CHA);
    else
        CheckRadioButton(IDC_RADIO12_KEEP, IDC_RADIO12_CHA, IDC_RADIO12_KEEP);
    ucSecurityFlag[3] = ucSecurityFlag[3] >> 1;

    switch (ucSecurityFlag[3] & 0x7)
    {
    case 1:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_4CRY);
        break;
    case 3:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_812);
        break;
    case 4:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_2);
        break;
    case 5:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_8);
        break;
    case 6:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_4);
        break;
    case 7:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_12);
        break;
    default:
        CheckRadioButton(IDC_RADIO11_2, IDC_RADIO11_812, IDC_RADIO11_2);
        break;
    }

    if (ucSecurityFlag[4] == 0xFF)
        ((CButton*)GetDlgItem(IDC_CHECK1))->SetCheck(TRUE);
    else
        ((CButton*)GetDlgItem(IDC_CHECK1))->SetCheck(FALSE);

    if (ucSecurityFlag[5] == 0xFF)
        ((CButton*)GetDlgItem(IDC_CHECK2))->SetCheck(TRUE);
    else
        ((CButton*)GetDlgItem(IDC_CHECK2))->SetCheck(FALSE);

    if (ucSecurityFlag[6] == 0xFF)
        ((CButton*)GetDlgItem(IDC_CHECK3))->SetCheck(TRUE);
    else
        ((CButton*)GetDlgItem(IDC_CHECK3))->SetCheck(FALSE);

    if (ucSecurityFlag[7] == 0xFF)
        ((CButton*)GetDlgItem(IDC_CHECK4))->SetCheck(TRUE);
    else
        ((CButton*)GetDlgItem(IDC_CHECK4))->SetCheck(FALSE);

    return TRUE;
}

BOOL CDLGSH79F1621F::OutputData(const struct chip_info_c *chip, unsigned char *pRegBuff, unsigned long nBufferLen, unsigned long *pDataLen)
{
    UCHAR ucSecurityFlag[8];

    UINT op1 = GetCheckedRadioButton(IDC_RADIO1_DIS, IDC_RADIO1_EN);
    UINT op2 = GetCheckedRadioButton(IDC_RADIO2_DIS, IDC_RADIO2_EN);
    UINT op3 = GetCheckedRadioButton(IDC_RADIO3_RST, IDC_RADIO3_IO);
    UINT op4 = GetCheckedRadioButton(IDC_RADIO4_LEST, IDC_RADIO4_SEST);
    UINT op5 = GetCheckedRadioButton(IDC_RADIO5_DIS, IDC_RADIO5_EN);
    UINT op6 = GetCheckedRadioButton(IDC_RADIO6_43V, IDC_RADIO6_21V);
    UINT op7 = GetCheckedRadioButton(IDC_RADIO7_INV, IDC_RADIO7_VAL);
    UINT op8 = GetCheckedRadioButton(IDC_RADIO8_NOR, IDC_RADIO8_INV);
    UINT op9 = GetCheckedRadioButton(IDC_RADIO9_KEEP, IDC_RADIO9_CHA);
    UINT op10 = GetCheckedRadioButton(IDC_RADIO10_12, IDC_RADIO10_0212);
    UINT op11 = GetCheckedRadioButton(IDC_RADIO11_2, IDC_RADIO11_812);
    UINT op12 = GetCheckedRadioButton(IDC_RADIO12_KEEP, IDC_RADIO12_CHA);
    UINT op13 = GetCheckedRadioButton(IDC_RADIO13_CHA, IDC_RADIO13_KEEP);
    UINT op14 = ((CButton*)GetDlgItem(IDC_CHECK1))->GetCheck();
    UINT op15 = ((CButton*)GetDlgItem(IDC_CHECK2))->GetCheck();
    UINT op16 = ((CButton*)GetDlgItem(IDC_CHECK3))->GetCheck();
    UINT op17 = ((CButton*)GetDlgItem(IDC_CHECK4))->GetCheck();

    UINT option1 = 0, option2 = 0, option3 = 0, option4 = 0x80;

    if (op1 == IDC_RADIO1_EN)
        op1 = 1 << 7;
    else
        op1 = 0;

    if (op2 == IDC_RADIO2_EN)
        op2 = 1 << 6;
    else
        op2 = 0;

    if (op3 == IDC_RADIO3_IO)
        op3 = 1 << 5;
    else
        op3 = 0;

    switch (op4)
    {
    case IDC_RADIO4_LEST:
        op4 = 0;
        break;
    case IDC_RADIO4_LER:
        op4 = 0x8;
        break;
    case IDC_RADIO4_SER:
        op4 = 0x10;
        break;
    case IDC_RADIO4_SEST:
        op4 = 0x18;
        break;
    default:
        break;
    }


    if (op5 == IDC_RADIO5_EN)
        op5 = 1 << 7;
    else
        op5 = 0;

    if (op6 == IDC_RADIO6_21V)
        op6 = 1 << 6;
    else
        op6 = 0;

    if (op7 == IDC_RADIO7_VAL)
        op7 = 1 << 3;
    else
        op7 = 0;

    if (op8 == IDC_RADIO8_INV)
        op8 = 1 << 1;
    else
        op8 = 0;


    if (op9 == IDC_RADIO9_CHA)
        op9 = 1 << 1;
    else
        op9 = 0;

    switch (op10)
    {
    case IDC_RADIO10_12:
        op10 = 0;
        break;
    case IDC_RADIO10_12812:
        op10 = 0x3;
        break;
    case IDC_RADIO10_12802:
        op10 = 0x6;
        break;
    case IDC_RADIO10_3212:
        op10 = 0xa;
        break;
    case IDC_RADIO10_3202:
        op10 = 0xd;
        break;
    case IDC_RADIO10_0212:
        op10 = 0xe;
        break;
    default:
        op10 = 0xF;
        break;
    }


    switch (op11)
    {
    case IDC_RADIO11_2:
        op11 = 0x10;
        break;
    case IDC_RADIO11_4:
        op11 = 0x18;
        break;
    case IDC_RADIO11_8:
        op11 = 0x14;
        break;
    case IDC_RADIO11_12:
        op11 = 0x1C;
        break;
    case IDC_RADIO11_4CRY:
        op11 = 0x4;
        break;
    case IDC_RADIO11_812:
        op11 = 0xc;
        break;
    default:
        op11 = 0x10;
        break;
    }

    if (op12 == IDC_RADIO12_CHA)
        op12 = 1 << 1;
    else
        op12 = 0;

    if (op13 == IDC_RADIO13_KEEP)
        op13 = 1;
    else
        op13 = 0;

    if (op14 == TRUE)
        op14 = 0xFF;
    else
        op14 = 0;

    if (op15 == TRUE)
        op15 = 0xFF;
    else
        op15 = 0;

    if (op16 == TRUE)
        op16 = 0xFF;
    else
        op16 = 0;

    if (op17 == TRUE)
        op17 = 0xFF;
    else
        op17 = 0;

    option1 |= op1 | op2 | op3 | op4;
    option2 |= op5 | op6 | op7 | op8;
    option3 |= op9 | op10;
    option4 |= op11 | op12 | op13;

    ucSecurityFlag[0] = option1;
    ucSecurityFlag[1] = option2;
    ucSecurityFlag[2] = option3;
    ucSecurityFlag[3] = option4;
    ucSecurityFlag[4] = op14;
    ucSecurityFlag[5] = op15;
    ucSecurityFlag[6] = op16;
    ucSecurityFlag[7] = op17;

    memcpy(pRegBuff, ucSecurityFlag, 8);
    *m_pDataLen = 8;

    return TRUE;
}
