#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static char private_data = '\0';

static MAGIC *
get_existing_magic(SV *sv)
{
    MAGIC *mg;

    for (mg = mg_find(sv, PERL_MAGIC_ext);  mg;  mg = mg->mg_moremagic)
        if (mg->mg_ptr == &private_data)
            return mg;

    return 0;
}

static MAGIC *
get_magic(SV *sv)
{
    MAGIC *mg;

    mg = get_existing_magic(sv);
    if (mg)
        return mg;

    /* didn't find any iterator magic, so create some */
    return sv_magicext(sv, newSViv(0), PERL_MAGIC_ext, 0, &private_data, 0);
}

MODULE = Array::Each::Override      PACKAGE = Array::Each::Override

PROTOTYPES: DISABLE

int
_advance_iterator(sv)
    SV *sv
    PREINIT:
    MAGIC *mg;
    int i;
    CODE:
    if (!SvROK(sv))
        croak("Argument to Array::Each:::Override:_advance_iterator must be a reference");
    sv = SvRV(sv);
    if (SvTYPE(sv) != SVt_PVAV)
        croak("Argument to Array::Each::Override::_advance_iterator must be an array reference");
    mg = get_magic(sv);
    i = SvIVX(mg->mg_obj);
    sv_setiv(mg->mg_obj, i + 1);
    RETVAL = i;
    OUTPUT:
    RETVAL

void
_clear_iterator(sv)
    SV *sv
    PREINIT:
    MAGIC *mg;
    CODE:
    if (!SvROK(sv))
        XSRETURN_EMPTY;
    sv = SvRV(sv);
    if (SvTYPE(sv) != SVt_PVAV)
        XSRETURN_EMPTY;
    mg = get_existing_magic(sv);
    if (!mg)
        XSRETURN_EMPTY;
    sv_setiv(mg->mg_obj, 0);
