/// \author 		Oleksandr Kiyenko
/// \version 	1.0
/// \date		2017
/// \copyright	SPDX: BSD-3-Clause 2016-2017 Trenz Electronic GmbH

#ifndef _ARTY_Z7_10_FOC
#define _ARTY_Z7_10_FOC


#pragma SDS data access_pattern(rbuf:SEQUENTIAL)
void pf_read_stream(long long int *rbuf);
#pragma SDS data access_pattern(rabuf:SEQUENTIAL)
void pf_read_adc_stream(long long int *rabuf);
#pragma SDS data access_pattern(wbuf:SEQUENTIAL)
void pf_write_stream(long long int *wbuf);
#pragma SDS data access_pattern(dbuf:SEQUENTIAL)
void dbg_write_stream(long long int *dbuf);

#endif
