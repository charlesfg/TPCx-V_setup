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
/*
**  C Program to access the TPC-V trade-status transaction in PostgreSQL using ODBC
**
**  Created by:  Andrew Bond
**
**  Copyright 2011 Red Hat, Inc.
*/

#include <stdio.h>
#include <sql.h>
#include <sqlext.h>
#include <memory.h>
#include <stdlib.h>

static void extract_error(
    char *fn,
    SQLHANDLE handle,
    SQLSMALLINT type)
{
    SQLINTEGER	 i = 0;
    SQLINTEGER	 native;
    SQLCHAR	 state[ 7 ];
    SQLCHAR	 text[256];
    SQLSMALLINT	 len;
    SQLRETURN	 ret;

    fprintf(stderr,
            "\n"
            "The driver reported the following diagnostics whilst running "
            "%s\n\n",
            fn);

    do
    {
            printf("before SQLGetDiagRec\n");
        ret = SQLGetDiagRec(type, handle, ++i, state, &native, text,
                            sizeof(text), &len );
            printf("before if\n");
        if (SQL_SUCCEEDED(ret))
            printf("%s:%ld:%ld:%s\n", state, (long) i, (long) native, text);
    }
    while( ret == SQL_SUCCESS );
            printf("leaving extract_error\n");
}



int
main(int argc, char* argv[]) {
  SQLHENV env;
  SQLHDBC dbc;
  SQLHSTMT stmt;
  SQLRETURN ret; /* ODBC API return status */
  SQLCHAR outstr[1024];
  SQLSMALLINT outstrlen;
  SQLCHAR myquery[250];
  SQLINTEGER a;
  SQLCHAR b[ 25 ];
  SQLCHAR c[ 20 ];
  SQLCHAR d[ 49 ];
  SQLBIGINT e;
  SQL_TIMESTAMP_STRUCT f;
  SQLCHAR g [ 10 ];
  SQLCHAR h [ 12 ];
  SQLCHAR i [ 15 ];
  SQLINTEGER j;
  SQLCHAR k [ 49 ];
  SQLREAL l;
  SQLCHAR m [ 70 ];
  SQLCHAR n [ 100 ];
  SQLLEN indicator[ 13 ];
  SQLCHAR cname[250];
  SQLSMALLINT nlptr;
  SQLSMALLINT dtptr;
  SQLULEN csptr;
  SQLSMALLINT ddptr;
  SQLSMALLINT nptr;
  SQLSMALLINT numcol; 

  SQLLEN num_found;

  char dsn[100];

  int	curcol = 0;
  unsigned long	myval;

  if (argc == 1)
    strcpy(dsn, "DSN=PSQL1");	// Default
  else
    if (argc == 2) {
      strcpy(dsn, "DSN=");
      strcat(dsn, argv[1]);
      strcat(dsn, ";");
    } else {
      fprintf(stderr, "usage: %s [Data Source]\n", argv[0]);
      exit(1);
    }
    

  /* Allocate an environment handle */
  SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &env);
  /* We want ODBC 3 support */
  SQLSetEnvAttr(env, SQL_ATTR_ODBC_VERSION, (void *) SQL_OV_ODBC3, 0);
  /* Allocate a connection handle */
  SQLAllocHandle(SQL_HANDLE_DBC, env, &dbc);
  /* Connect to the DSN mydsn */
  ret = SQLDriverConnect(dbc, NULL, (SQLCHAR *) dsn, SQL_NTS,
			 outstr, sizeof(outstr), &outstrlen,
			 SQL_DRIVER_COMPLETE);
  if (SQL_SUCCEEDED(ret)) {
    printf("Connected\n");
    printf("Returned connection string was:\n\t%s\n", outstr);
    if (ret == SQL_SUCCESS_WITH_INFO) {
      printf("Driver reported the following diagnostics\n");
      extract_error("SQLDriverConnect", dbc, SQL_HANDLE_DBC);
    }
  } else {
    fprintf(stderr, "Failed to connect\n");
    extract_error("SQLDriverConnect", dbc, SQL_HANDLE_DBC);
  }

/*
  strcpy((char *) myquery, "select * from TradeStatusFrame1(43000000001)");
*/
  strcpy((char *) myquery, "select * from TradeStatusFrame1(?)");
  printf("Query: %s\n", myquery);

  SQLAllocStmt(dbc, &stmt);

  myval=43000000001;
  printf("myval=%ld\n", myval);
  ret=SQLBindParameter(stmt, 1, SQL_PARAM_INPUT, SQL_C_UBIGINT, SQL_INTEGER, 0, 0, &myval, 0, NULL);
  if (ret==SQL_SUCCESS) {
    printf("Bind Success\n");
  }
  else {
    printf("Bind Failure\n");
  }

  ret=SQLExecDirect(stmt, myquery, sizeof(myquery));
  if (SQL_SUCCEEDED(ret)) {
    printf("SQL Success\n");
    if (ret == SQL_SUCCESS_WITH_INFO) {
      printf("SQLExecDirect reported the following diagnostics\n");
      extract_error("SQLExecDirect", dbc, SQL_HANDLE_DBC);
    }

  ret = SQLNumResultCols(stmt,&numcol);
  printf("Number of colums = %d\n", numcol);
  ret = SQLRowCount(stmt,&num_found);
  printf("Number of rows = %d\n", num_found);

  
  while (curcol++ < numcol) {
    ret=SQLDescribeCol(stmt, curcol, cname, 250, &nlptr, &dtptr, &csptr, &ddptr, &nptr); 
    printf("SQLDescribeCol returns:  cname=%s, nlptr=%d, dtptr=%d, csptr=%lu, ddptr=%d, nptr=%d\n",
	   cname, nlptr, dtptr, (unsigned long) csptr, ddptr, nptr);
  }


/* Need to query for results here */
   ret = SQLBindCol( stmt, 1, SQL_C_CHAR, b, sizeof(b), &indicator[ 1 ] );
   ret = SQLBindCol( stmt, 2, SQL_C_CHAR, c, sizeof(c), &indicator[ 2 ] );
   ret = SQLBindCol( stmt, 3, SQL_C_CHAR, d, sizeof(d), &indicator[ 3 ] );
   ret = SQLBindCol( stmt, 4, SQL_C_SBIGINT, &e, sizeof(e), &indicator[ 4 ] );
   ret = SQLBindCol( stmt, 5, SQL_C_TIMESTAMP, &f, sizeof(f), &indicator[ 5 ] );
   ret = SQLBindCol( stmt, 6, SQL_C_CHAR, g, sizeof(g), &indicator[ 6 ] );
   ret = SQLBindCol( stmt, 7, SQL_C_CHAR, h, sizeof(h), &indicator[ 7 ] );
   ret = SQLBindCol( stmt, 8, SQL_C_CHAR, i, sizeof(i), &indicator[ 8 ] );
   ret = SQLBindCol( stmt, 9, SQL_C_LONG, &j, sizeof(j), &indicator[ 9 ] );
   ret = SQLBindCol( stmt, 10, SQL_C_CHAR, k, sizeof(k), &indicator[ 10 ] );
   ret = SQLBindCol( stmt, 11, SQL_C_FLOAT, &l, sizeof(l), &indicator[ 11 ] );
   ret = SQLBindCol( stmt, 12, SQL_C_CHAR, m, sizeof(m), &indicator[ 12 ] );
   ret = SQLBindCol( stmt, 13, SQL_C_CHAR, n, sizeof(n), &indicator[ 13 ] );
   while (SQL_SUCCEEDED(ret = SQLFetch(stmt))) {
     printf("b=%s\n", b);
     printf("c=%s\n", c);
     printf("d=%s\n", d);
     printf("e=%lld\n", (long long int) e);
     printf("f=%d/%02d/%02d %02d:%02d:%02d\n",
	    f.year, f.month, f.day, f.hour, f.minute, f.second);
     printf("g=%s\n", g);
     printf("h=%s\n", h);
     printf("i=%s\n", i);
     printf("j=%d\n", j);
     printf("k=%s\n", k);
     printf("l=%10.2f\n", l);
     printf("m=%s\n", m);
     printf("n=%s\n", n);
   }
    
    SQLDisconnect(dbc);		/* disconnect from driver */
  } else {
    fprintf(stderr, "SQL Failed\n");
    extract_error("SQLExecDirect", dbc, SQL_HANDLE_DBC);
  }
  /* free up allocated handles */
  SQLFreeHandle(SQL_HANDLE_DBC, dbc);
  SQLFreeHandle(SQL_HANDLE_ENV, env);

  return 0;
}

