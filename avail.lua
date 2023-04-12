function avail_actions()
    local avail={}
    
    --local dpx,dpy=can_deposit(-1)
    --if dpx and dpy then ins(avail,{'Deposit',id=52,sp=mget(dpx,dpy)})
    if can_turn(-1) then ins(avail,{'Turn',id=52})
    elseif can_chat(-1) then ins(avail,{'Chat',id=52})
    elseif can_climb(-1,0) then ins(avail,{'Climb',id=52})
    elseif can_pickup(-1) then ins(avail,{'Get',id=52,sp=mget(x-1,y)}) 
    elseif can_move(-1) then ins(avail,{'Move',id=52}) end
    --local dpx,dpy=can_deposit(1)
    --if dpx and dpy then ins(avail,{'Deposit',id=50,sp=mget(dpx,dpy)})
    if can_turn(1) then ins(avail,{'Turn',id=50})
    elseif can_chat(1) then ins(avail,{'Chat',id=50})
    elseif can_climb(1,0) then ins(avail,{'Climb',id=50})
    elseif can_pickup(1) then ins(avail,{'Get',id=50,sp=mget(x+1,y)})
    elseif can_move(1) then ins(avail,{'Move',id=50}) end
    --local dpx,dpy=can_deposit(0)
    --if dpx and dpy then ins(avail,{'Deposit',id=49,sp=mget(dpx,dpy)})
    if can_climb(0,-1) then ins(avail,{'Climb',id=49})
    elseif can_jump() then ins(avail,{'Jump',id=49}) end
    if can_climb(0,1) then ins(avail,{'Climb',id=51})
    elseif can_fall() then ins(avail,{'Fall',id=51}) end
    local dpx,dpy=can_depositZ()
    if can_depositZ() then ins(avail,{'Deposit',id=53,sp=mget(dpx,dpy)})
    elseif can_travel() then ins(avail,{'Travel',id=53}) 
    elseif can_drop() then ins(avail,{'Drop',id=53,sp=next_drop()}) end
    local gid=can_reclaim()
    if gid then ins(avail,{'Reclaim',id=54,sp=gid})
    elseif can_cut() then ins(avail,{'Cut',id=54,sp=44})
    end
    if spec.forced_reset then ins(avail,{'Reset room',id=55}) end
    --elseif can_cube() then ins(avail,{'Enter',id=54,sp=61}) end
    
    return avail
end

function can_move(dx)
    if x+dx<cur_room.mx or x+dx>=cur_room.mx+cur_room.mw then return false end
    local i=0
    --local falling=not fget(mget(x,y+1),1)
    --if falling and fget(mget(x+dx,y),1) then return false end
    while fget(mget(x,y-i),2) do
        if fget(mget(x+dx,y-i),1) then return false end
        i=i+1
    end
    return true
end

function can_pickup(dx)
    if not fget(mget(x+dx,y),2) then return false end
    
    if mget(x,y-1)==61 then
        local cx,cy=119,65
        while mget(cx,cy)>=0 do
            if mget(cx,cy)==0 then return true end
            cx=cx-1
            if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
        end
    end

    return (not (fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my))) or not fget(mget(x,y+1),1)
end

function can_jump()
    if not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then return false end
    if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then
        return false
    end
    return true
end

function can_fall()
    return not fget(mget(x,y+1),1)
end

function can_drop()
    if inv_len()==0 then return false end
    local dx=1
    if plrflip==1 then dx=-1 end
    if x+dx>=cur_room.mx+cur_room.mw or x+dx<cur_room.mx then return false end
    if not fget(mget(x,y+1),1) and not fget(mget(x+dx,y+1),1) and not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return false end
    if (mget(x+dx,y)==0 or mget(x+dx,y)==12) and (fget(mget(x+dx,y+1),1) or fget(mget(x+dx,y+1),5)) then return true end
    return false
end

no_room_msg='Can\'t travel - no room for inventory'
function can_travel()
    local i=0
    local has_gate=nil
    while fget(mget(x,y-i),2) do
        if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count==0 then has_gate=posstr(x,y-i); break end
        i=i+1
    end
    if not has_gate then return false end
    local connect=gates[has_gate].connect
    if not connect then return false end
    local gx,gy=strpos(connect)
    local tgt_room
    for i,r in ipairs(rooms) do
        if gx>=r.mx and gy>=r.my and gx<r.mx+r.mw and gy<r.my+r.mh then
            tgt_room=r
            break
        end
    end
    local i=0
    local top=gy
    while not fget(mget(gx,top-1),1) and not (top-1<tgt_room.my) do
        top=top-1
    end
    while i<=inv_len() do 
        if fget(mget(gx,top+i),1) or top+i>=tgt_room.my+tgt_room.mh then
            if chat_msg~=no_room_msg then
                chat_msg=no_room_msg
                chat_t=nil
                sfx(13,'E-5',#chat_msg,2) 
            end
            return false
        end
        i=i+1
    end
    return true
end

function can_reclaim()
    local i=0
    local overlap=false
    while fget(mget(x,y-i),2) do
    if (hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count+1<=gates[posstr(x,y-i)].maxcount) then overlap=gates[posstr(x,y-i)]; break end
    i=i+1
    end
    if not overlap or mget(x,y-i-1)==33 then return false end
    
    if mget(x,y-1)==61 then
        local cx,cy=119,65
        local full=false
        while mget(cx,cy)>0 do
            cx=cx-1
            if cx==116 then cx=119; cy=cy-1; if cy<64 then full=true; break end end
        end
        if not full then
            return overlap.id
        end
    end
    
    if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then
        if not fget(mget(x,y+1),1) then
            return overlap.id
        end
        return false
    end
    return overlap.id
end

function can_turn(tdx)
    if tdx<0 then return plrflip==0 else return plrflip==1 end
end

function can_cube()
    i=1
    while fget(mget(x,y-i),2) do
        if mget(x,y-i)==61 then return true end
        i=i+1
    end
    return false
end

function can_depositZ()
    local i=1
    while fget(mget(x,y-i),2) do
        if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)] and gates[posstr(x,y-i)].count>0 then 
            if mget(x,y-i)==61 then
                local cx,cy=119,65
                while mget(cx,cy)>=0 do
                    if mget(cx,cy)==gates[posstr(x,y-i)].id then return cx,cy end
                    cx=cx-1
                    if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
                end
            elseif gates[posstr(x,y-i)].id==mget(x,y-i) then
                return x,y-i
            end 
        end
        i=i+1
    end
end

function can_climb(dx,dy)
    if dx~=0 and not can_move(dx) then return false end
    if dy==-1 then
        if fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my then return false end
        if fget(mget(x,y),5) or (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return true end
        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return false end
    end
    if dy==1 then
        if y+1>=cur_room.my+cur_room.mh then return false end
    end
    return (hidden[posstr(x+dx,y+dy)] and hidden[posstr(x+dx,y+dy)].id==44) or fget(mget(x+dx,y+dy),5)
end

function can_chat(dx)
    return not chat_msg and not can_turn(dx) and fget(mget(x+dx,y),4)
end

function can_cut()
    if inv_has(46) and hidden[posstr(x,y)] and fget(hidden[posstr(x,y)].id,5) then
        if fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my then 
            return not fget(mget(x,y+1),1)
        end
        return true
    end
end
