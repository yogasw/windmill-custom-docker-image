core.register_action("log_response_body", { "http-res" }, function(txn)
    local path = txn.sf:path()
    if path:match("^/api/w/admins/jobs/run/f/u/") or
       path:match("^/api/w/[^/]+/jobs/run") or
       path:match("^/api/r") then

        local res_body = txn:get_var("res.body")
        if res_body then
            txn:set_var("res.body", res_body:gsub('"', '\\"'))
        end
    end
end)
