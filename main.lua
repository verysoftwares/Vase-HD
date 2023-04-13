require 'utility'
require 'file-io'
require 'avail'
require 'inventory'
require 'bezier'
require 'sprite'

-- title:  Vase
-- author: verysoftwares
-- desc:   tile-based collectathon
-- script: lua

t=0
x=2
y=7
pi=math.pi
sin=math.sin
cos=math.cos
ins=table.insert
rem=table.remove
fmt=string.format
sub=string.sub

plrflip=0

--inventory={}

hidden={}

spec={}


function move(dx)
    if can_turn(dx) then
        if dx<0 then plrflip=1 else plrflip=0 end

        dx=0
        local snd=false
        local i=1
        local ir=false
        --[[while fget(mget(x,y-i),2) do
            if hidden[posstr(x+dx,y-i)] and hidden[posstr(x+dx,y-i)].id==12 and gates[posstr(x+dx,y-i)].count>0 then
                --hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
                if gates[posstr(x+dx,y-i)].id==mget(x,y-i) then
                    ir=y-i
                    gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                    local connect=gates[posstr(x+dx,y-i)].connect
                    if connect then
                    gates[connect].count=gates[connect].count-1
                    end
                    sfx(2,'E-4',30,2)
                    snd=true
                end
                if mget(x,y-i)==61 then
                    local cx,cy=117,64
                    while mget(cx,cy)>=0 do
                        if mget(cx,cy)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then 
                            mset(cx,cy,0)
                            gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                            local connect=gates[posstr(x+dx,y-i)].connect
                            if connect then
                            gates[connect].count=gates[connect].count-1
                            end
                            sfx(2,'E-4',30,2)
                            snd=true
                            break
                        end
                        cx=cx+1
                        if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
                    end
                end
            end

            i=i+1
        end
        ]]
        if ir then inv_rem(ir) end
        if not snd then sfx(0,'E-1',6,2) end

        reveal_hidden()

        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then fall() end
        return true
    end
    if can_pickup(dx) then
        if dx<0 then plrflip=1 else plrflip=0 end
        --ins(inventory,{sp=mget(x-1,y)})
        local oldy2=y 
        local yadjust=false
        
        if (mget(x,y-1)~=61 or box_full()) and (fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my) then
            local i=0
            while fget(mget(x,y-i),2) and fget(mget(x,y-i-1),2) do
                mset(x,y-i,mget(x,y-i-1)) 
                i=i+1
            end
            if fget(mget(x,y-i),2) then mset(x,y-i,0) end
            if mget(x,y+1)>0 then hidden[posstr(x,y+1)]={id=mget(x,y+1),t=t} end
            y=y+1
            yadjust=true
        end
        
        if mget(x,y-1)==61 then
            local cx,cy=119,65
            local cont=false
            while mget(cx,cy)>0 do
                cx=cx-1
                if cx==116 then cx=119; cy=cy-1; if cy<64 then cont=true; break end end
            end
            if not cont then
            mset(cx,cy,mget(x+dx,y))
            mset(x+dx,y,0)
            sfx(1,'E-4',22,2)
            return
            end
        end

        local oldy=y-inv_len()-1
        local old=mget(x,oldy)

        local i=inv_len()
        while fget(mget(x,y-i),2) and mget(x,y-i)~=33 do
            if mget(x,y-i-1)>0 then hidden[posstr(x,y-i-1)]={id=mget(x,y-i-1),t=t} end
            mset(x,y-i-1,mget(x,y-i))
            mset(x,y-i,0)
            i=i-1
        end

        if mget(x,y-1)>0 then hidden[posstr(x,y-1)]={id=mget(x,y-1),t=t} end
        mset(x,y-1,mget(x+dx,oldy2))
        mset(x+dx,oldy2,0)

        local i=1
        local ir=false
        local snd=false
        --[[
        while fget(mget(x,y-i),2) do
            if y-i==oldy and fget(old,3) then
                hidden[posstr(x,y-i)]={id=old,t=t}
                --trace(y-i)
                --trace(mget(x,y-i))
                --trace(old)
                --trace(gates[posstr(x,y-i)].id)
                if mget(x,y-i)==gates[posstr(x,y-i)].id and gates[posstr(x,y-i)].count>0 then
                    --trace('inv rem')
                    ir=y-i
                    gates[posstr(x,y-i)].count=gates[posstr(x,y-i)].count-1
                    local connect=gates[posstr(x,y-i)].connect
                    if connect then gates[connect].count=gates[connect].count-1 end
                    sfx(2,'E-4',30,2)
                    snd=true
                end
            end
            i=i+1
        end
        ]]

        if ir then inv_rem(ir) end

        reveal_hidden()

        if not snd then sfx(1,'E-4',22,2) end

        if mget(x,y-1)==61 and not boxget then
            rooms[4].visited=true
            boxget=true
        end

        if not yadjust and not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then fall() end
        
        return true
    elseif can_move(dx) or can_climb(dx,0) then
        if dx<0 then plrflip=1 else plrflip=0 end
        
        local snd=false
        local i=0
        local ir=false
        --[[while fget(mget(x,y-i),2) do
            if fget(mget(x+dx,y-i),3) then
                --hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
                if mget(x,y-i)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then
                    ir=y-i
                    gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                    local connect=gates[posstr(x+dx,y-i)].connect
                    if connect then
                    gates[connect].count=gates[connect].count-1
                    end
                    sfx(2,'E-4',30,2)
                    snd=true
                end
                if mget(x,y-i)==61 then
                    local cx,cy=117,64
                    while mget(cx,cy)>=0 do
                        if mget(cx,cy)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then 
                            mset(cx,cy,0)
                            gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                            local connect=gates[posstr(x+dx,y-i)].connect
                            if connect then
                            gates[connect].count=gates[connect].count-1
                            end
                            sfx(2,'E-4',30,2)
                            snd=true
                            break
                        end
                        cx=cx+1
                        if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
                    end
                end
            end
            if mget(x+dx,y-i)>0 then
                hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
            end
            mset(x+dx,y-i,mget(x,y-i))
            mset(x,y-i,0)
            i=i+1
        end
        ]]
        -- move inventory
        while fget(mget(x,y-i),2) do
            if mget(x+dx,y-i)>0 then
                hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
            end
            mset(x+dx,y-i,mget(x,y-i))
            mset(x,y-i,0)
            i=i+1
        end
        
        x=x+dx
        if ir then inv_rem(ir) end
        
        if not snd then sfx(0,'E-1',6,2) end
        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) then fall() end

        reveal_hidden()
        return true
    end     
end

function reveal_hidden()
    for k,h in pairs(hidden) do
        local hx,hy=strpos(k)
        if (h.t~=t or y-inv_len()>hy or y<hy) and (not fget(mget(hx,hy),2) or (mget(hx,hy)==33 and hx~=x)) then
        mset(hx,hy,h.id)
        hidden[k]=nil
        end
    end
end

function draw_room(r)
    if r.visited then
    rect(r.x-4,r.y-4,r.mw*8+2*4,r.mh*8+2*4,0)
    rectb(r.x-4,r.y-4,r.mw*8+2*4,r.mh*8+2*4,5)
    rect(r.x,r.y,r.mw*8,r.mh*8,r.c)
    map(r.mx,r.my,r.mw,r.mh,r.x,r.y,0,1,remap)
    end
    if r==rooms[4] and r.x<240+8 then
        rect(r.x-10-4,r.y+2-4,12,12,0)
        rectb(r.x-10-4,r.y+2-4,12,12,12)
        spr(61,r.x-8-4,r.y-4+2+2,0)
    end
end

function transition()
    local clear=true
    for i,r in ipairs(rooms) do
        if r.tx then 
            clear=false
            if r.tx<r.x then
            r.x=r.x-3
            if r.x<=r.tx then r.x=r.tx; r.tx=nil end
            elseif r.tx>r.x then
            r.x=r.x+3
            if r.x>=r.tx then r.x=r.tx; r.tx=nil end
            elseif r.tx==r.x then r.tx=nil end
            --if r.x>=240 then r.visited=false end
        end
        if r.ty then
            clear=false
            if r.ty<r.y then
            r.y=r.y-3
            if r.y<=r.ty then r.y=r.ty; r.ty=nil end
            elseif r.ty>r.y then
            r.y=r.y+3
            if r.y>=r.ty then r.y=r.ty; r.ty=nil end
            elseif r.ty==r.y then r.ty=nil end
            --if r.y>=136 then r.visited=false end
        end
    end

    cls(0)
    
    for i,r in ipairs(rooms) do
        if r~=rooms[4] and r.x<240 and r.y<136 and r.x+r.mw*8>=0 and r.y+r.mh*8>=0 then 
        -- box will be drawn on top of everything
        draw_room(r)
        end
    end
    
    mark_gates()
    
    draw_room(rooms[4])
    
    if clear then 
    local i=0
    local offy=0
    while i<=inv_len() do 
        if fget(mget(gatetx,gatety-i),1) or gatety-i<tgt_room.my then
        offy=offy+1
        end
        i=i+1
    end
    local i=0
    while fget(mget(x,y-i),2) do 
    mset(gatetx,gatety-i+offy,mget(x,y-i))
    mset(x,y-i,0)
    i=i+1
    end
    --[[if x==6 and gatey==6 then
    --gates[posstr(8,3)].count=0
    elseif x==21 and gatey==3 then
    elseif x==23 and gatey==6 then
    rooms[3].visited=false
    elseif x==8 and gatey==3 then
    rooms[2].visited=false
    end]]
    --[[
    for i,r in ipairs(rooms) do
        if r.x>=240 or r.y>=136 or r.x+r.mw*8<0 or r.y+r.mh*8<0 then
            r.visited=false
        end
    end]]
    TIC=update 
    hidden[posstr(gatetx,gatety)]={id=12,t=t}
    mset(x,gatey,12)
    x=gatetx; y=gatety+offy
    cur_room=tgt_room
    cur_room.visited=true
    chat_msg=nil
    chat_t=nil
    save_room()
    end
    
    t=t+1
end


function fall()
    if not (hidden[posstr(x,y)] and fget(hidden[posstr(x,y)].id,1)) then
    local i=1
    while fget(mget(x,y-i),2) do
        mset(x,y-i+1,mget(x,y-i))
        i=i+1
    end
    if fget(mget(x,y-i+1),2) then mset(x,y-i+1,0) end
    else
    mset(x,y,0)
    end
    y=y+1
    if mget(x,y)>0 then hidden[posstr(x,y)]={id=mget(x,y),t=t} end
    
    if y>=cur_room.my+cur_room.mh then
    local i=0
    while fget(mget(x,y-i),2) do
        mset(x,y-i,0)
        i=i+1
    end
    sfx(12,'E-4',64,2)
    TIC=delay; dt=t+1
    end

    reveal_hidden()
end

function box_in_room(r)
    for gx=r.mx,r.mx+r.mw do for gy=r.my,r.my+r.mh do
        if mget(gx,gy)==61 then return true end
    end end
    return false
end

function inv_has(sp)
    local i=1
    while fget(mget(x,y-i),2) do
        if mget(x,y-i)==sp then return true end
        if mget(x,y-i)==61 then
            local cx,cy=119,65
            while 1 do
                if mget(cx,cy)==sp then return true end
                cx=cx-1
                if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
            end
        end
        i=i+1
    end
    return false
end

function action()
    if btnp(0) and can_climb(0,-1) then
        --local i=inv_len()+1
        --while fget(mget(x,y-i+1),2) do
        for i=inv_len()+1,1,-1 do
            if mget(x,y-i)>0 then hidden[posstr(x,y-i)]={id=mget(x,y-i),t=t} end
            mset(x,y-i,mget(x,y-i+1))
            mset(x,y-i+1,0)
            i=i-1
        end
        mset(x,y,0)
        
        y=y-1

        sfx(0,'E-1',6,2)

        reveal_hidden()
        
        return true
    elseif btnp(0) and can_jump() then 
        --local i=inv_len()
        --while fget(mget(x,y-i),2) do
        for i=inv_len(),0,-1 do
            --if mget(x,y-i)>0 and not fget(mget(x,y-i),2) then
            --      hidden[posstr(x,y-i)]={id=mget(x,y-i),t=t}
            --end
            if mget(x,y-i-1)>0 and not fget(mget(x,y-i-1),2) then
                hidden[posstr(x,y-i-1)]={id=mget(x,y-i-1),t=t}
            end
            if mget(x,y-i-1)~=33 then
            mset(x,y-i-1,mget(x,y-i))
            end
            i=i-1
        end
        --mset(x,y-i,0)
        mset(x,y,0)
        y=y-1
        local snd=false
        --[[if inv_len()>0 and gates[posstr(x,y-inv_len())] and gates[posstr(x,y-inv_len())].count>0 then
                if gates[posstr(x,y-inv_len())].id==mget(x,y-inv_len()) then
                gates[posstr(x,y-inv_len())].count=gates[posstr(x,y-inv_len())].count-1
                local connect=gates[posstr(x,y-inv_len())].connect
                if connect then
                gates[connect].count=gates[connect].count-1
                end
                sfx(2,'E-4',30,2)
                snd=true
                inv_rem(y-inv_len())
                else
                if mget(x,y-inv_len())==61 then
                    local cx,cy=117,64
                    while mget(cx,cy)>=0 do
                        if mget(cx,cy)==gates[posstr(x,y-inv_len())].id and gates[posstr(x,y-inv_len())].count>0 then 
                            mset(cx,cy,0)
                            gates[posstr(x,y-inv_len())].count=gates[posstr(x,y-inv_len())].count-1
                            local connect=gates[posstr(x,y-inv_len())].connect
                            if connect then
                            gates[connect].count=gates[connect].count-1
                            end
                            sfx(2,'E-4',30,2)
                            snd=true
                            break
                        end
                        cx=cx+1
                        if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
                    end
                end
                end
        end
        ]]
        if not snd then sfx(9,'E-5',22,2) end
        
        reveal_hidden()
        
        return true
    end
    --local chat=(btnp(2) and can_chat(-1)) or (btnp(3) and can_chat(1))
    --local fell=false
    if btnp(1) and can_fall() then
        fall()
        --fell=true
        if y<cur_room.my+cur_room.mh then 
        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
        sfx(8,'E-5',16,2) 
        else
        sfx(0,'E-1',6,2)
        end
        end
        return true
    end
    if btnp(2) and can_chat(-1) then 
        if mget(x-1,y)==65 then chat_msg='The order and orientation of pickups matter.' end
        if mget(x-1,y)==66 then chat_msg='These vases are all mine! You can\'t have them!' end
        if mget(x-1,y)==68 then win=true; chat_msg=fmt('This is the end. Rooms discovered: %d/%d in %d turns',explored_count(),#rooms,turn) end
        sfx(13,'E-5',#chat_msg,2)
        chat_t=nil
        if can_fall() then fall() end
        return true
    elseif btnp(2) then 
        return move(-1)
    end
    if btnp(3) and can_chat(1) then 
        if mget(x+1,y)==65 then chat_msg='The order and orientation of pickups matter.' end
        if mget(x+1,y)==66 then chat_msg='These vases are all mine! You can\'t have them!' end
        if mget(x+1,y)==68 then win=true; win=true; chat_msg=fmt('This is the end. Rooms discovered: %d/%d in %d turns',explored_count(),#rooms,turn) end
        sfx(13,'E-5',#chat_msg,2)
        chat_t=nil
        if can_fall() then fall() end
        return true
    elseif btnp(3) then 
        return move(1)
    end
    --if btnp(4) and can_deposit() then
    if btnp(4) and can_depositZ() then
        local dx=0
        local snd=false
        local i=0
        local ir=false
        while fget(mget(x,y-i),2) do
            --if fget(mget(x+dx,y-i),3) then
            if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count>0 then 
                if mget(x,y-i)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then
                    ir=y-i
                    gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                    local connect=gates[posstr(x+dx,y-i)].connect
                    if connect then
                    gates[connect].count=gates[connect].count-1
                    end
                    sfx(2,'E-4',30,2)
                    snd=true
                end
                if mget(x,y-i)==61 then
                    local cx,cy=117,64
                    while mget(cx,cy)>=0 do
                        if mget(cx,cy)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then 
                            mset(cx,cy,0)
                            gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
                            local connect=gates[posstr(x+dx,y-i)].connect
                            if connect then
                            gates[connect].count=gates[connect].count-1
                            end
                            sfx(2,'E-4',30,2)
                            snd=true
                            break
                        end
                        cx=cx+1
                        if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
                    end
                end
            end
            i=i+1
        end
        
        if ir then inv_rem(ir) end
        
        reveal_hidden()
        
        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then fall() end 
    elseif btnp(4) and can_travel() then
        local i=0
        while fget(mget(x,y-i),2) do
        if gates[posstr(x,y-i)] and gates[posstr(x,y-i)].count==0 then 
            gatey=y-i
            if x==6 and y-i==6 then
            rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10
            tgt_room=rooms[2]
            if not rooms[2].visited then
            rooms[2].x=240+8
            rooms[2].visited=true
            end
            rooms[2].tx=240-rooms[2].mw*8-64+24+6-10
            gatetx=8; gatety=3
            if box_in_room(rooms[1]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
            end
            if x==21 and y-i==3 then
            rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4
            rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4
            tgt_room=rooms[3]
            rooms[3].y=136/2-(17-4)*8/2+8*3
            rooms[3].x=240+8
            rooms[3].visited=true
            rooms[3].tx=240-rooms[3].mw*8-64+24+6-10
            if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[3]) and boxget or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9; rooms[3].tx=rooms[3].tx-9 end
            gatetx=23; gatety=6
            end
            if x==8 and y-i==3 then
            rooms[1].tx=240/2-7*8/2
            rooms[2].tx=240+8
            tgt_room=rooms[1]
            gatetx=6; gatety=6
            if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[1]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-10*8 end
            end
            if x==23 and y-i==6 then
            rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4+8*12-8*3-4
            rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4+8*12-8*3-4
            rooms[3].tx=240+8
            tgt_room=rooms[2]
            gatetx=21; gatety=3
            if box_in_room(rooms[3]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
            end
            if x==14 and y-i==1 then
            for i=1,3 do
                rooms[i].ty=rooms[i].y+8*8+16-4
            end
            rooms[5].x=240/2-8*4
            rooms[5].visited=true
            rooms[5].ty=16
            tgt_room=rooms[5]
            gatetx=15; gatety=128
            if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==15 and y-i==128 then
            for i=1,3 do
                rooms[i].ty=rooms[i].y-(8*8+16-4)
            end
            rooms[5].ty=-(8*8+16-4)
            tgt_room=rooms[2]
            gatetx=14; gatety=1
            if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==16 and y-i==7 then
            for i=1,5 do
                if i~=4 then rooms[i].ty=rooms[i].y-(8*7) end
            end
            rooms[6].visited=true
            rooms[6].ty=136-(12*8-4)
            tgt_room=rooms[6]
            gatetx=21; gatety=19
            if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[6]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==21 and y-i==19 then
            for i=1,5 do
                if i~=4 then rooms[i].ty=rooms[i].y+(8*7) end
            end
            rooms[6].ty=136+8
            tgt_room=rooms[2]
            gatetx=16; gatety=7
            if box_in_room(rooms[6]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==16 and y-i==18 then
            for i=1,5 do
                if i~=4 and rooms[i].visited then rooms[i].ty=rooms[i].y+(8*7); rooms[i].tx=rooms[i].x+11*8 end
            end
            rooms[6].ty=136+8
            tgt_room=rooms[1]
            gatetx=0; gatety=6
            if box_in_room(rooms[6]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[1]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==0 and y-i==6 then
            for i=1,5 do
                if i~=4 and rooms[i].visited then rooms[i].ty=rooms[i].y-(8*7); rooms[i].tx=rooms[i].x-11*8 end
            end
            rooms[6].visited=true
            rooms[6].ty=136-(12*8-4)
            tgt_room=rooms[6]
            gatetx=16; gatety=18
            if box_in_room(rooms[1]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[6]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==17 and y-i==129 then
            for i=1,6 do
                if i~=4 and rooms[i].visited then rooms[i].tx=rooms[i].x-8*4+4 end
            end
            rooms[7].visited=true
            rooms[7].tx=240-8*13
            tgt_room=rooms[7]
            gatetx=20; gatety=129
            if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[7]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==20 and y-i==129 then
            for i=1,6 do
                if i~=4 and rooms[i].visited then rooms[i].tx=rooms[i].x+8*4-4 end
            end
            rooms[7].tx=240+8
            tgt_room=rooms[5]
            gatetx=17; gatety=129
            if box_in_room(rooms[7]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==12 and y-i==131 then
            for i=1,6 do
                if i~=4 and rooms[i].visited then rooms[i].oldvisited=rooms[i].visited; rooms[i].tx=rooms[i].x+240; rooms[i].ty=rooms[i].y+136 end
            end
            rooms[8].visited=true
            rooms[8].tx=240/2-rooms[8].mw*8/2
            tgt_room=rooms[8]
            gatetx=9; gatety=132
            if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[8]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==9 and y-i==132 then
            for i=1,6 do
                if i~=4 and rooms[i].oldvisited then rooms[i].visited=true; rooms[i].tx=rooms[i].x-240; rooms[i].ty=rooms[i].y-136 end
            end
            rooms[8].tx=-8*8
            tgt_room=rooms[5]
            gatetx=12; gatety=131
            if box_in_room(rooms[8]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==28 and y-i==128 then
            for i=1,8 do
                if i~=4 then rooms[i].tx=rooms[i].x-240; rooms[i].ty=rooms[i].y+136 end
            end
            rooms[9].visited=true
            rooms[9].ty=136/2-rooms[9].mh*8/2
            tgt_room=rooms[9]
            gatetx=31; gatety=130
            if box_in_room(rooms[7]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[9]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==31 and y-i==130 then
            for i=1,8 do
                if i~=4 then rooms[i].tx=rooms[i].x+240; rooms[i].ty=rooms[i].y-136 end
            end
            rooms[9].ty=-rooms[9].mh*8-8
            tgt_room=rooms[7]
            gatetx=28; gatety=128
            if box_in_room(rooms[9]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[7]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==13 and y-i==7 then
            for i=1,8 do
                if i~=4 then rooms[i].tx=rooms[i].x+240; rooms[i].ty=rooms[i].y-136 end
            end
            rooms[10].visited=true
            rooms[10].ty=136/2-rooms[10].mh*8/2
            tgt_room=rooms[10]
            gatetx=12; gatety=18
            if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[10]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            if x==12 and y-i==18 then
            for i=1,8 do
                if i~=4 then rooms[i].tx=rooms[i].x-240; rooms[i].ty=rooms[i].y+136 end
            end
            rooms[10].ty=136+8
            tgt_room=rooms[2]
            gatetx=13; gatety=7
            if box_in_room(rooms[10]) and not inv_has(61) then rooms[4].tx=240+8 end
            if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
            end
            TIC=transition
            sfx(7,'E-5',70,2) 
            if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
            mset(x,y,33)
            return true
        end         
        i=i+1
        end
        
        return true
    elseif btnp(4) and can_drop() then
        local dx=1
        if plrflip==1 then dx=-1 end
        local sp,ix,iy=next_drop()
        -- switch vine type
        if sp==60 then sp=44 end

        if ix<116 then inv_rem(iy)
        else mset(ix,iy,0) end
        
        local snd=false
        if mget(x+dx,y)==12 then
            if gates[posstr(x+dx,y)].id==sp and gates[posstr(x+dx,y)].count>0 then
                gates[posstr(x+dx,y)].count=gates[posstr(x+dx,y)].count-1
                local connect=gates[posstr(x+dx,y)].connect
                if connect then gates[connect].count=gates[connect].count-1 end
                sfx(2,'E-4',30,2)
                snd=true
            else
                hidden[posstr(x+dx,y)]={id=mget(x+dx,y),t=t}
                mset(x+dx,y,sp)
            end
        else
        mset(x+dx,y,sp)
        end
                
        if not snd then
        sfx(10,'E-1',22,2)
        end
        
        if not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) and not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
        fall()
        if y<cur_room.my+cur_room.mh then 
        if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
        sfx(8,'E-5',16,2) 
        else
        sfx(0,'E-1',6,2)
        end
        end
        end
        
        reveal_hidden()
        
        return true
    end
    
    if btnp(5) and can_reclaim() then
        --local g=posstr(x,y)
        
        local i=0
        local g
        while fget(mget(x,y-i),2) do
        if (hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count<gates[posstr(x,y-i)].maxcount) then g=posstr(x,y-i); break end
        i=i+1
        end
        
        if not g then return end
    
        gates[g].count=gates[g].count+1
        local connect=gates[g].connect
        if connect then
        gates[connect].count=gates[connect].count+1
        end

        local full=false
        if mget(x,y-1)==61 then
            local cx,cy=119,65
            while mget(cx,cy)>0 do
                cx=cx-1
                if cx==116 then cx=119; cy=cy-1; if cy<64 then full=true; break end end
            end
            if not full then
                mset(cx,cy,gates[g].id)
            end
        end

        if mget(x,y-1)~=61 or full then
        local yadjust=false             
        if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then                                    
            if not fget(mget(x,y+1),1) then
                local i=1 
                while fget(mget(x,y-i),2) do
                    mset(x,y-i+1,mget(x,y-i))
                    i=i+1
                end
                mset(x,y-i+1,0)
                y=y+1
                yadjust=true
            end
        end
    
        mset(x,y-inv_len()-1,gates[g].id)
        end
        
        sfx(11,'E-4',43,2)
        
        if not yadjust and not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then
        fall()
        end
        
        reveal_hidden()
        
        return true
    elseif btnp(5) and can_cut() then

        local yadjust=false
        
        if (mget(x,y-1)~=61 or box_full()) and (fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my) then
            local i=0
            while fget(mget(x,y-i),2) and fget(mget(x,y-i-1),2) do
                mset(x,y-i,mget(x,y-i-1)) 
                i=i+1
            end
            if fget(mget(x,y-i),2) then mset(x,y-i,0) end
            if mget(x,y+1)>0 then hidden[posstr(x,y+1)]={id=mget(x,y+1),t=t} end
            y=y+1
            yadjust=true
        end

        local room=true
        if mget(x,y-1)==61 then
            local cx,cy=119,65
            while mget(cx,cy)>0 do
                cx=cx-1
                if cx==116 then cx=119; cy=cy-1; if cy<64 then room=false; break end end
            end
            if room then
                mset(cx,cy,60)
            end
        end
        if mget(x,y-1)~=61 or not room then
            if mget(x,y-inv_len()-1)>0 then hidden[posstr(x,y-inv_len()-1)]={id=mget(x,y-inv_len()-1),t=t} end
            --oops wrong side of the stack
            --mset(x,y-inv_len()-1,60)
            for i=inv_len(),1,-1 do
                mset(x,y-i-1,mget(x,y-i))
            end
            mset(x,y-1,60)
        end
        sfx(14,'E-3',32,2)
        if yadjust then hidden[posstr(x,y-1)]=nil
        else hidden[posstr(x,y)]=nil end

        if not yadjust and not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then
        fall()
        end
        
        reveal_hidden()
        return true
    elseif btnp(5) and can_cube() then
        return
    end

end

turn=0
function update()
    local oldx,oldy=x,y
    
    local turn_passed=action()
    
    if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
    mset(x,y,33)
    
    if turn_passed then 
        turn=turn+1
        if chat_msg==no_room_msg then
            chat_msg=nil
            chat_t=nil
        end
        -- special events
        if not spec.gem and x==17 and y==25 and mget(x,y-1)==62 and chat_msg then
            chat_msg='Why didn\'t you listen to me?'
            sfx(13,'E-5',#chat_msg,2)
            chat_t=nil
            spec.gem=true
        end
        if not spec.thief and ((x==34 and y==128) or (x==35 and y==127)) then
            chat_msg='Thief! This soft-lock prison is your punishment!'
            sfx(13,'E-5',#chat_msg,2)
            chat_t=nil
            spec.thief=true
            spec.forced_reset=true
        end
    end

    --[[
    if btnp(4) then zt=t; st=t end
    
    if not zt then
    cls(t*0.06)
    print("HELLO WORLD!",0,0,(t-16)*0.06%16)
    else
    cls(zt*0.06)
    print("HELLO WORLD!",0,0,(zt-16)*0.06%16)
    local j=0
    for i=math.max(0,(t-st-128)*0.25),(t-st)*0.25 do
    for c=0,4-1 do
    local a=j*2+t*0.08+c*2*pi/4
    local a2=j*2+t*0.08+(c+1)*2*pi/4
    line(x+cos(a)*(i+1)*3,y+sin(a)*(i+1)*3,x+cos(a2)*(i+1)*3,y+sin(a2)*(i+1)*3,(zt-16)*0.06%16)
    end
    j=j+1
    end 
    end
    ]]
    
    cls(0)

    if win then
        local tw=print('You win!',0,-6)
        for tx=0,240,tw+8 do for ty=0,136,7 do
        --print('You win!',rooms[5].x+rooms[5].mw/2*8-tw/2,rooms[5].y-12,t*0.2)
        print('You win!',tx,ty,t*0.2)
        end end
    end

    for i,r in ipairs(rooms) do 
        if r.x<240 and r.y<136 and r.x+r.mw*8>=0 and r.y+r.mh*8>=0 then
        draw_room(r)
        end
    end
    
    mark_gates()

    local sortgates={}
    --[[for k,g in pairs(gates) do
        local gx,gy=strpos(k)
        if gx>=cur_room.mx and gx<cur_room.mx+cur_room.mw and gy>=cur_room.my and gy<cur_room.my+cur_room.mh then
            ins(sortgates,g)
            g.x=gx; g.y=gy
        end
    end]]
    if TIC~=delay then
    ins(sortgates,{x=cur_room.mx-1,y=cur_room.my,count=-1})
    end
    table.sort(sortgates,function(a,b) return a.y<b.y or (a.y==b.y and a.x>b.x) end)
    local l,r=0,0
    for i,g in ipairs(sortgates) do
        local gx,gy=g.x,g.y
        local bx,by,bw,bh
        
        if g.count>0 then
            local tw=print(fmt('%dx',g.count),0,-6,12)
            bw=tw+4+8; bh=8+4
        elseif g.count==0 then
            local tw=print('OPEN',0,-6,12)
            bw=tw+4; bh=6+4+1
        elseif g.count==-1 then
            local avail=avail_actions()
            bw=0
            for j,a in ipairs(avail) do
                local aw=0
                aw=aw+print(a[1],0,-6,12,false,1,true)+1
                aw=aw+8
                if a.sp then aw=aw+8 end
                if aw>bw then bw=aw end
            end
            bw=bw+4; bh=#avail*9+4-1
        end
        
        if g.x<cur_room.mx+cur_room.mw/2 then
            bx=cur_room.x-bw-2; by=cur_room.y-2+l
        else
            bx=cur_room.x+cur_room.mw*8+2; by=cur_room.y-2+r
        end
        
        -- we now have our bx,by,bw,bh
        
        line(cur_room.x+(gx-cur_room.mx)*8+4,cur_room.y+(gy-cur_room.my)*8+4,bx+bw/2,by+bh/2,12)
        rect(bx,by,bw,bh,0)
        rectb(bx,by,bw,bh,12)

        if g.count>0 then
            local tw=print(fmt('%dx',g.count),bx+2,by+3,12)
            local oy=0
            if g.id==11 or g.id==61 then oy=-1 end
            spr(g.id,bx+2+tw,by+2+oy,0)
        elseif g.count==0 then
            print('OPEN',bx+2,by+3,12)
        elseif g.count==-1 then
            local avail=avail_actions()
            for j,a in ipairs(avail) do
                spr(a.id,bx+2,by+2+(j-1)*9,0)
                local tw=print(a[1],bx+2+8+1,by+2+(j-1)*9+1,12,false,1,true)
                if a.sp then 
                    local oy=0
                    if a.sp==11 or a.sp==61 then oy=-1 end
                    spr(a.sp,bx+2+8+tw+1,by+2+(j-1)*9+oy,0) 
                end
            end
        end
                
        if g.x<cur_room.mx+cur_room.mw/2 then
            l=l+bh+2
        else
            r=r+bh+2
        end
    end
    
    if y<cur_room.my+cur_room.mh then
    spr(33,cur_room.x+(x-cur_room.mx)*8,cur_room.y+(y-cur_room.my)*8,0,1,plrflip)
    end
        
    if cur_room==rooms[3] and box_in_room(rooms[3]) and rooms[4].visited and rooms[4].x>240-5*8 then
        for i=1,4 do 
        if i==4 or (i>=1 and i<=3 and rooms[3].x>240-rooms[3].mw*8-64+24+6-10-9) then
        rooms[i].x=rooms[i].x-3
        end 
        end
    end

    -- reset with A
    if btnp(6) then
    sfx(12,'E-4',64,2)
    TIC=delay; dt=t+1
    end
    
    if chat_msg then
        if not chat_t then chat_t=1 end
      local tw=print('"'..sub(chat_msg,1,chat_t)..'"',0,-6,12,false,1,true)
        rect(cur_room.x+cur_room.mw*8/2-tw/2-1,cur_room.y+cur_room.mh*8+8-1,tw+2,8,0)
      print('"'..sub(chat_msg,1,chat_t)..'"',cur_room.x+cur_room.mw*8/2-tw/2,cur_room.y+cur_room.mh*8+8,12,false,1,true)
        chat_t=chat_t+1
    end

    --if cur_room==rooms[5] and not win then win=true end
    
    t=t+1
end

function explored_count()
    local out=0
    for i,r in ipairs(rooms) do
        if r.visited then out=out+1 end
    end
    return out
end

rooms={
{mx=0,my=4,mw=7,mh=17-4,x=240/2-7*8/2,y=136/2-(17-4)*8/2,c=15,visited=true,explored=true},
{mx=7,my=1,mw=22-7+1,mh=10-1,x=240/2-10*8/2,y=136/2-(17-4)*8/2,c=8,visited=false},
{mx=23,my=6,mw=7,mh=11,x=240,y=136/2-(17-4)*8/2+8*3,c=2,visited=false},
{mx=116,my=64,mw=4,mh=4,x=240+8,y=136/2,c=1,visited=false},
{mx=11,my=128,mw=8,mh=8,x=240/2-4*8,y=0-8*8,c=3,visited=false},
{mx=13,my=18,mw=9+1+1,mh=8+1,x=240/2-6*8,y=136,c=0,visited=false},
{mx=19,my=127,mw=11,mh=7,x=240,y=136/2-5*8-4,c=10,visited=false},
{mx=4,my=129,mw=7,mh=7,x=-8*8,y=136/2-4*8,c=13,visited=false},
{mx=30,my=124,mw=7,mh=9,x=240/2-3*8,y=-9*8,c=11,visited=false},
{mx=1,my=17,mw=12,mh=10,x=240/2-6*8,y=136,c=0,visited=false},
}
cur_room=rooms[1]
gates={
['6:6']={id=11,count=3,connect='8:3'},
['8:3']={id=11,count=3,connect='6:6'},
['14:1']={id=11,count=6,connect='15:128'},
['21:3']={id=11,count=3,connect='23:6'},
['13:7']={id=60,count=1,connect='12:18'},
['12:18']={id=60,count=1,connect='13:7'},
['16:7']={id=11,count=1,connect='21:19'},
['23:6']={id=11,count=3,connect='21:3'},
['15:128']={id=11,count=6,connect='14:1'},
['21:19']={id=11,count=1,connect='16:7'},
['16:18']={id=62,count=1,connect='0:6'},
['0:6']={id=62,count=1,connect='16:18'},
['12:131']={id=46,count=1,connect='9:132'},
['9:132']={id=46,count=1,connect='12:131'},
['17:129']={id=11,count=2,connect='20:129'},
['20:129']={id=11,count=2,connect='17:129'},
['28:128']={id=60,count=1,connect='31:130'},
['31:130']={id=60,count=1,connect='28:128'},
['1:23']={id=29,count=1},
}
for k,g in pairs(gates) do
    g.maxcount=g.count
end


function mark_gates()
for i,r in ipairs(rooms) do if r.visited then
    for k,g in pairs(gates) do
        local gx,gy=strpos(k)
        if gx>=r.mx and gx<r.mx+r.mw and gy>=r.my and gy<r.my+r.mh then
            if mget(gx,gy)==12 and g.count>0 then
            rect(r.x+(gx-r.mx)*8,r.y+(gy-r.my)*8,8,8,5)
            shadowspr(g.id,r.x+(gx-r.mx)*8,r.y+(gy-r.my)*8)
            end
            if not fget(mget(gx,gy-1),2) then
            --local tw=print(g.count,0,-6)
            --print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2-1,0)
            --print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2+1,0)
            --print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1-1,r.y+(gy-r.my)*8-8+2,0)
            --print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1+1,r.y+(gy-r.my)*8-8+2,0)
            --print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2,12)
            local msg=fmt('%d/%d',g.maxcount-g.count,g.maxcount)
            local tw=print(msg,0,-6,12,false,1,true)
            print(msg,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2-1,0,false,1,true)
            print(msg,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2+1,0,false,1,true)
            print(msg,r.x+(gx-r.mx)*8+4-tw/2+1-1,r.y+(gy-r.my)*8-8+2,0,false,1,true)
            print(msg,r.x+(gx-r.mx)*8+4-tw/2+1+1,r.y+(gy-r.my)*8-8+2,0,false,1,true)
            print(msg,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2,12,false,1,true)
            end
        end
    end
    end end
end

function remap(tile,x,y)
    local flip=0
    if tile==12 then tile=12+t*(0.2)%4 end
    if tile==33 and plrflip then flip=plrflip end
    return tile,flip,0
end



TIC=update

DEBUG=false
if DEBUG then
    --x=27;y=129;mset(x,y,33);mset(x,y-1,60);rooms[1].visited=false;cur_room=rooms[7];cur_room.visited=true;cur_room.x=240-8*13
    x=13-3;y=3;mset(x,y,33);mset(x,y-1,60);mset(x,y-2,46);rooms[1].visited=false;cur_room=rooms[2];cur_room.visited=true;cur_room.x=240-rooms[2].mw*8-64+24+6-10
end

--save_room()