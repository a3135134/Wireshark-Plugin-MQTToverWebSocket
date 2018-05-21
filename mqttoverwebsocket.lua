do
    -- calling tostring() on random FieldInfo's can cause an error, so this func handles it
    local function getstring(finfo)
        local ok, val = pcall(tostring, finfo)
        if not ok then val = "(unknown)" end
        return val
    end
    
    -- Create a new dissector
    MQTToverWebsocket = Proto("MQTToverWebsocket", "MQTT over Websocket")
    mqtt_dissector = Dissector.get("mqtt")
    -- The dissector function
    function MQTToverWebsocket.dissector(buffer, pinfo, tree)
        local fields = { all_field_infos() }
        local websocket_flag = false
        for i, finfo in ipairs(fields) do
            if (finfo.name == "websocket") then
                websocket_flag = true
            end
            if (websocket_flag == true and finfo.name == "data") then
                local str1 = getstring(finfo)
                local str2 = string.gsub(str1, ":", "")
                local bufFrame = ByteArray.tvb(ByteArray.new(str2))
                mqtt_dissector = Dissector.get("mqtt")
                --mqtt_dissector:call(finfo.source, pinfo, tree) #9 BUG
                mqtt_dissector:call(bufFrame, pinfo, tree)
                --mqtt_dissector:call(finfo.value, pinfo, tree)
                websocket_flag = false
                pinfo.cols.protocol = "MQTT over Websocket"
            end
    end
        
        --ws_dissector_table = DissectorTable.get("ws.port")
        --ws_dissector_table:add("443",mqtt_dissector)
    end
    -- Register the dissector
    --ws_dissector_table = DissectorTable.get("ws.port")
    --ws_dissector_table:remove(443, mqtt_dissector)
    --ws_dissector_table:add(443, MQTTPROTO)
    --ws_dissector_table:add_for_decode_as(mqtt_dissector)
    register_postdissector(MQTToverWebsocket)
end