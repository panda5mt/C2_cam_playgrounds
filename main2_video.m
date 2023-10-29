% C2カメラで記録したビデオデータで深度推定をする
% GMSL-USB3変換を利用した際はCX3の律速により10FPSでしか行えない
% 簡易的には問題ない精度と思われる

clc;

% 結果をムービーで記録
out_mov = false;

% 光源推定バッファ
pos_buf = ones(20, 3) .* [0.5, 0.5, 0.8];

% C2カメラで録画したデータ(各自用意)
vid_read = VideoReader('./img/c2cam_sample.mov');

if out_mov
    vid_write = VideoWriter('./img/encode00','MPEG-4');
    vid_write.FrameRate = 10;
    open(vid_write);
end

while hasFrame(vid_read)

    % グレースケールに変換
    RGB_I = readFrame(vid_read);
    %I = imresize(RGBI, [960*2 1280*2]);
    I = im2double(im2gray(RGB_I)); 
   
   
    % 光源の方向を設定
    %
    %   y
    %   ↑
    %   |
    %   |   z (奥行き、画面内へ)
    %   |  ↙
    %   |
    %   ───────────→ x
    %

    

    % 光源推定(ロジック非公開)
    % 光源推定は使用環境によって最適な状態は異なります
    % 各自で用意してください
    % 試験的に固定値(例:pos = [0.5, 0.5, -0.7];)で試すことも可能です
    pos_buf(1,:) = estimate_lightsource(I);
    
    % 毎フレームごとに光源推定をするが、中央値を正しい光源位置とする
    pos = median(pos_buf, 1);

    % 法線推定(ロジック非公開)
    % こちらも光源推定の結果に大きく依存します
    % 各自で実装してください
    [p, q] = estimate_normal(I, pos);
    pos_buf = circshift(pos_buf,[1 0]); % pos_bufを下にシフト

    % 推定された法線から深度推定(公開)
    Z = fcmethod(p, q);


    % 結果表示
    figure(1);
    tiledlayout(1,2);
    nexttile
    imshow(RGB_I);

    nexttile
    clims = [-100 200];
    imagesc(Z,clims); colormap("jet"); colorbar; title('depth estimate');

    drawnow

     if out_mov
        writeVideo(vid_write,getframe(gcf)); 
    end
end

if out_mov, close(vid_write); end
