function [p, q] = estimate_normal(image, light_pos)
    % 画像の読み込み (グレースケールと仮定)
    if size(image,3) > 1
        image = im2gray(image);
    end
    lx = light_pos(1) ;
    ly = light_pos(2) ;
    lz = light_pos(3) ;
    
    % 画像勾配を計算（輝度から法線を推定）
    p = image * lx / lz;
    q = image * ly / lz;
end