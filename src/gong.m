function gong()
% Produces a sound.

    data=load('gong.mat');
    try 
        sound(data.y,data.Fs);
    catch
        printf('GOOOONNNNG!!! (sound is not enable)')
    end
    
end