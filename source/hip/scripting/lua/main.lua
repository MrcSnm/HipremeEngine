
local x = 0;
local y = 200;

function HipInitialize()


end

function HipUpdate()
    
    x = x+1
end


function HipRender()

    fillRectangle(x, y, 400, 300);
    endGeometry();
end