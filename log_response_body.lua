core.register_action("log_response_body", { "http-res" }, function(txn)
    local response_body = ""
    local http = txn.http

    if http then
        local len = http:res_get_body_length()
        if len and len > 0 then
            local body = http:res_get_body()
            if body then
                response_body = body:gsub('"', '\\"')  -- escape quote for JSON log
            end
        end
    end

    txn:set_var("res.body", response_body or "-")
    core.Info("Response body: " .. response_body)
end)
