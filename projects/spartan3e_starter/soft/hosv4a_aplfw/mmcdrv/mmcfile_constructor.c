/** 
 * Hyper Operating System  Application Framework
 *
 * @file  mmcfile_constructor.c
 * @brief %jp{memory file �R���X�g���N�^}%en{Memory File  constructor}
 *
 * Copyright (C) 2008 by Project HOS
 * http://sourceforge.jp/projects/hos/
 */


#include "mmcfile_local.h"


void MmcFile_Constructor(C_MMCFILE *self, const T_FILEOBJ_METHODS *pMethods, C_MMCDRV *pMmcDrv, int iMode)
{
	/* �e�N���X�R���X�g���N�^ */
	FileObj_Constructor(&self->FileObj, pMethods, &pMmcDrv->DrvObj, iMode);
	
	/* �����o�ϐ������� */
	self->FilePos = 0;
}


/* end of file */