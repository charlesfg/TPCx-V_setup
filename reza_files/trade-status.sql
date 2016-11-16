/*
 * Legal Notice
 *
 * This document and associated source code (the "Work") is a part of a
 * benchmark specification maintained by the TPC.
 *
 * The TPC reserves all right, title, and interest to the Work as provided
 * under U.S. and international laws, including without limitation all patent
 * and trademark rights therein.
 *
 * No Warranty
 *
 * 1.1 TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE INFORMATION
 *     CONTAINED HEREIN IS PROVIDED "AS IS" AND WITH ALL FAULTS, AND THE
 *     AUTHORS AND DEVELOPERS OF THE WORK HEREBY DISCLAIM ALL OTHER
 *     WARRANTIES AND CONDITIONS, EITHER EXPRESS, IMPLIED OR STATUTORY,
 *     INCLUDING, BUT NOT LIMITED TO, ANY (IF ANY) IMPLIED WARRANTIES,
 *     DUTIES OR CONDITIONS OF MERCHANTABILITY, OF FITNESS FOR A PARTICULAR
 *     PURPOSE, OF ACCURACY OR COMPLETENESS OF RESPONSES, OF RESULTS, OF
 *     WORKMANLIKE EFFORT, OF LACK OF VIRUSES, AND OF LACK OF NEGLIGENCE.
 *     ALSO, THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
 *     QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR NON-INFRINGEMENT
 *     WITH REGARD TO THE WORK.
 * 1.2 IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THE WORK BE LIABLE TO
 *     ANY OTHER PARTY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO THE
 *     COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST PROFITS, LOSS
 *     OF USE, LOSS OF DATA, OR ANY INCIDENTAL, CONSEQUENTIAL, DIRECT,
 *     INDIRECT, OR SPECIAL DAMAGES WHETHER UNDER CONTRACT, TORT, WARRANTY,
 *     OR OTHERWISE, ARISING IN ANY WAY OUT OF THIS OR ANY OTHER AGREEMENT
 *     RELATING TO THE WORK, WHETHER OR NOT SUCH AUTHOR OR DEVELOPER HAD
 *     ADVANCE NOTICE OF THE POSSIBILITY OF SUCH DAMAGES.
 */
--
--  PostgreSQL SQL commands to implement the TPC-V transaction trade-status 
--
--  Created by:  Andrew Bond
--
--  Copyright 2011 Red Hat, Inc.
--

create or replace function TradeStatusFrame1 (	in acct_id IDENT_T, 
					out l_name_out varchar(25),
					out f_name_out varchar(20),
					out b_name_out varchar(49),
					out id_out trade_t,
					out dts_out timestamp,
					out st_name_out char(10),
					out tt_name_out char(12),
					out s_symb_out varchar(15),
					out qty_out s_qty_t,
					out exec_name_out varchar(49),
					out chrg_out value_t,
					out s_name_out varchar(70),
					out ex_name_out char(100)
) returns setof record
AS
$$
DECLARE
        l_name_tmp	varchar(25);	        
        f_name_tmp	varchar(20);       
        b_name_tmp	varchar(49);
BEGIN

	select  c_l_name,
		c_f_name,
		b_name
	into	l_name_tmp,
		f_name_tmp,
		b_name_tmp	
	from	customer_account,
		customer,
		broker
	where	ca_id = acct_id and
		c_id = ca_c_id and
		b_id = ca_b_id;

	return query 
	select
		l_name_tmp,
		f_name_tmp,
		b_name_tmp,
		t_id,
		t_dts,
		st_name,
		tt_name,
		t_s_symb,
		t_qty,
		t_exec_name,
		t_chrg,
		s_name,
		ex_name
	from	trade,
		status_type,
		trade_type,
		security,
		exchange
	where	t_ca_id = acct_id and
		st_id = t_st_id and
		tt_id = t_tt_id and
		s_symb = t_s_symb and
		ex_id = s_ex_id
	order by t_dts desc
	limit 50;
	
end;
$$ language plpgsql;
