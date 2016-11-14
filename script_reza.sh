psql -U postgres tpcv -c "\diS+" | cat
psql -U postgres tpcv -c "\ds+" | cat
psql -U postgres tpcv -c "\dT+" | cat
psql -U postgres tpcv -c "\d+" | cat
for TABLE in account_permission address broker charge commission_rate company company_competitor customer customer_account customer_taxrate exchange financial holding_summary industry last_trade news_xref sector security status_type taxrate trade_request trade_type watch_item watch_list zip_code cash_transaction daily_market holding holding_history news_item settlement trade trade_history; do
    psql -U postgres tpcv -c "\d+ $TABLE" | cat
done
for TABLE in account_permission address broker charge commission_rate company company_competitor customer customer_account customer_taxrate exchange financial holding_summary industry last_trade news_xref sector security status_type taxrate trade_request trade_type watch_item watch_list zip_code cash_transaction daily_market holding holding_history news_item settlement trade trade_history; do
    psql -U postgres tpcv -c "select count(*) from $TABLE" | cat
done
