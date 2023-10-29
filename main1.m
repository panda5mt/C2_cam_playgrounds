% C2カメラで記録したスチルデータで深度推定をする
clc;

% 画像読み込み
RGB_I = (imread('./img/c2snap4.png'));

% グレースケールに変換
if size(RGB_I,3) == 3
    I = rgb2gray(RGB_I);
else
    I = RGB_I;
end
I = im2double(I);


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

tic

% 光源推定(ロジック非公開)
% 光源推定は使用環境によって最適な状態は異なります
% 各自で用意してください
% 試験的に固定値(例:pos = [0.5, 0.5, -0.7];)で試すことも可能です
pos = estimate_lightsource(I);


% 法線推定(ロジック非公開)
% こちらも光源推定の結果に大きく依存します
% 各自で実装してください
[p,q] = estimate_normal(I, pos);

% 推定された法線から形状の再構築＝深度
Z = fcmethod(p, q);

toc(tic)

% 結果表示
figure(1);
tiledlayout(1,2);
nexttile
imshow(RGB_I);

nexttile
clims = [-100 200];
imagesc(Z,clims); colormap("jet"); colorbar; title('depth estimate');

drawnow

