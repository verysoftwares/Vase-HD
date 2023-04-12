function save_room()
    save_map={}; save_gates={}; save_hidden={}
    save_x=x; save_y=y
    save_turn=turn
    save_t=t
    save_flip=plrflip

    for sx=cur_room.mx,cur_room.mx+cur_room.mw-1 do for sy=cur_room.my,cur_room.my+cur_room.mh-1 do
        save_map[posstr(sx,sy)]=mget(sx,sy)
        if gates[posstr(sx,sy)] then save_gates[posstr(sx,sy)]=gates[posstr(sx,sy)].count end
    end end
    for sx=rooms[4].mx,rooms[4].mx+rooms[4].mw-1 do for sy=rooms[4].my,rooms[4].my+rooms[4].mh-1 do
        save_map[posstr(sx,sy)]=mget(sx,sy)
        if gates[posstr(sx,sy)] then save_gates[posstr(sx,sy)]=gates[posstr(sx,sy)].count end
    end end
    for k,h in pairs(hidden) do
        save_hidden[k]={id=h.id,t=h.t}
    end
end

function load_room()
    x=save_x; y=save_y
    turn=save_turn
    t=save_t
    plrflip=save_flip
    
    for sx=cur_room.mx,cur_room.mx+cur_room.mw-1 do for sy=cur_room.my,cur_room.my+cur_room.mh-1 do
        mset(sx,sy,save_map[posstr(sx,sy)])
        if gates[posstr(sx,sy)] then 
            gates[posstr(sx,sy)].count=save_gates[posstr(sx,sy)] 
            local connect=gates[posstr(sx,sy)].connect
            if connect then gates[connect].count=save_gates[posstr(sx,sy)] end
        end
    end end
    for sx=rooms[4].mx,rooms[4].mx+rooms[4].mw-1 do for sy=rooms[4].my,rooms[4].my+rooms[4].mh-1 do
        mset(sx,sy,save_map[posstr(sx,sy)])
        if gates[posstr(sx,sy)] then 
            gates[posstr(sx,sy)].count=save_gates[posstr(sx,sy)] 
            local connect=gates[posstr(sx,sy)].connect
            if connect then gates[connect].count=save_gates[posstr(sx,sy)] end
        end
    end end

    hidden={}
    for k,h in pairs(save_hidden) do
        hidden[k]={id=h.id,t=h.t}
    end

    chat_msg=nil
    chat_t=nil

    spec={}
    TIC=update
end

function delay()
    t=t+1
    if t-dt>=64 then load_room() end
end

