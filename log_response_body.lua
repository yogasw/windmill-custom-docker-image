core.register_action("log_response_body", { "http-res" }, function(txn)
    -- Escape response body
    local res_body = txn:get_var("res.body")
    if res_body then
        res_body = res_body:gsub('"', '\\"')
        txn:set_var("res.body", res_body)
    else
        txn:set_var("res.body", "")
    end

    -- Escape request body
    local req_body = txn:get_var("req.body")
    if req_body then
        req_body = req_body:gsub('"', '\\"')
        txn:set_var("req.body", req_body)
    else
        txn:set_var("req.body", "")
    end
end)
