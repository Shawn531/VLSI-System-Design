// file = 0; split type = patterns; threshold = 100000; total count = 0.
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "rmapats.h"

void  schedNewEvent (struct dummyq_struct * I1405, EBLK  * I1400, U  I622);
void  schedNewEvent (struct dummyq_struct * I1405, EBLK  * I1400, U  I622)
{
    U  I1669;
    U  I1670;
    U  I1671;
    struct futq * I1672;
    struct dummyq_struct * pQ = I1405;
    I1669 = ((U )vcs_clocks) + I622;
    I1671 = I1669 & ((1 << fHashTableSize) - 1);
    I1400->I664 = (EBLK  *)(-1);
    I1400->I665 = I1669;
    if (0 && rmaProfEvtProp) {
        vcs_simpSetEBlkEvtID(I1400);
    }
    if (I1669 < (U )vcs_clocks) {
        I1670 = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, I1400, I1670 + 1, I1669);
    }
    else if ((peblkFutQ1Head != ((void *)0)) && (I622 == 1)) {
        I1400->I667 = (struct eblk *)peblkFutQ1Tail;
        peblkFutQ1Tail->I664 = I1400;
        peblkFutQ1Tail = I1400;
    }
    else if ((I1672 = pQ->I1308[I1671].I687)) {
        I1400->I667 = (struct eblk *)I1672->I685;
        I1672->I685->I664 = (RP )I1400;
        I1672->I685 = (RmaEblk  *)I1400;
    }
    else {
        sched_hsopt(pQ, I1400, I1669);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
