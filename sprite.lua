t=0
function spritetest()
    love.graphics.clear(0x1a/255,0x1c/255,0x2c/255)
    for x=0,1280/128 do for y=0,720/128+1 do
    if (x+y)%2==0 then
    love.graphics.setColor(0x33/255,0x3c/255,0x57/255)
    love.graphics.rectangle('fill',x*128-t%128,y*128-t%128,128,128)
    sp_vase(x*128-t%128,y*128-t%128)
    end
    end end
    t=t+1
end

function sp_vase(sx,sy)
    love.graphics.setColor(0x25/255,0x71/255,0x79/255)
    love.graphics.setLineWidth(3)
    -- body
        local distx=28+4
        local disty=-6
        bezier(dot(sx+48+12-distx+12,sy+128+disty),dot(sx+0-distx,sy+48+disty),dot(sx+64+12-distx,sy+48+disty),dot(sx+32+12-distx,sy+24+disty))
        bezier(dot(sx+128-(48+12+12)+distx,sy+128+disty),dot(sx+128-(0)+distx,sy+48+disty),dot(sx+128-(64+12)+distx,sy+48+disty),dot(sx+128-(32+12)+distx,sy+24+disty))
    -- top corners
        local distx=12-4
        local disty=-6
        bezier(dot(sx+12+distx,sy+12+disty),dot(sx+distx,sy+12+disty),dot(sx+6+distx,sy+24+disty))
        bezier(dot(sx+128-(12+distx),sy+12+disty),dot(sx+128-(0+distx),sy+12+disty),dot(sx+128-(6+distx),sy+24+disty))
    -- handles
        local distx=4-4
        local disty=12-6
        bezier(dot(sx+12+distx,sy+12+disty),dot(sx+distx-8,sy+12+disty),dot(sx+12+distx,sy+48-6+disty))
        bezier(dot(sx+128-(12+distx),sy+12+disty),dot(sx+128-(distx-8),sy+12+disty),dot(sx+128-(12+distx),sy+48-6+disty))
    -- top
        bezier(dot(sx+12+12-4,sy+12-6),dot(sx+64,sy),dot(sx+128-(12+12-4),sy+12-6))
    -- bottom
        bezier(dot(sx+48+12-(28+4)+12,sy+128-6),dot(sx+64,sy+128+2),dot(sx+128-(48+12-(28+4)+12),sy+128-6))
end

love.draw=spritetest