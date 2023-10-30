% 法線から伝達関数を作り、frankot-Chellappaアルゴリズムで深度の復元をする
% 鏡面反射の場合などの対処はしていません。各自で実装してください

function depths = fcmethod(dx, dy, high_res)
    arguments
        dx = []
        dy = []
        high_res = false % 高解像度にしたい場合ここをtrueにする(処理時間が長くなる)
    end
    
    [M, N] = size(dx); % M,Nは画像のサイズ(行方向,列方向)
    
    MM = M;
    NN = N;
    
    % 見た目の分解能を向上させる(ゼロパディング)
    % 処理能力的に難しいのであればここはしなくてもいい
    if(high_res)
        dx_padded = padarray(dx, [M, N], 'post');
        dy_padded = padarray(dy, [M, N], 'post');
        dx = dx_padded;
        dy = dy_padded;
        [M, N] = size(dx);
    end
    % パディング処理ここまで
    
    
    % 法線(=勾配データ)のフーリエ変換に対応するx方向とy方向の周波数を指定する行列を設定
    [u, v] = meshgrid(linspace(-pi/2, pi/2, N), linspace(pi/2, -pi/2, M));
    
    u = ifftshift(u);
    v = ifftshift(v);
    
    % 深度再構築のための伝達関数の計算
    denom = (u .^ 2 + v .^ 2);
    denom(1, 1) = 1; %To avoid division by zero.
    
    % 法線の勾配の2DFFT
    FDX = fft2(dx);
    FDY = fft2(dy);
    
    % 伝達関数による深度の再構築
    Z = (1i * u .* FDX + 1i * v .* FDY) ./ denom;
    
    if(high_res)
        Z = -Z;
    end

    % 形状の再構築
    depths = real(ifft2(Z));
    
    % リサイズ
    depths = depths(1:MM, 1:NN);
end