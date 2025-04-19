core.register_action("log_response_body", { "http-res" }, function(txn)
    -- Escape response body
    local res_body = txn:get_var("res.body")
    if res_body then
        res_body = res_body:gsub('"', '\\"')
        txn:set_var("res.body", res_body)
    else
        txn:set_var("res.body", "")
    end
end)

core.register_action("read_full_request_body", { "http-req" }, function(txn)
    local body = txn.http:req_get_body()

    if body == nil then
        body = "-"
    end

    -- Escape double quotes for safe logging
    body = body:gsub('"', '\\"')

    txn:set_var("req.body", body)

    -- Optional: log ke stdout HAProxy
    core.Info("Request body: " .. body)
end)
