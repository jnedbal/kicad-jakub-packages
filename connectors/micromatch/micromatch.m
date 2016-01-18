fn = 'micromatch';
folder = '/usr/brlcad/bin/';



nrT = 8;
ter = 4 : 2 : 20;
w = [7.1 9.7 12.2 14.7 17.3 19.8 22.4 24.9 27.5];

fn = [fn, num2str(nrT)];

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');
%% chip body

W = w(ter == nrT) / 2;

H = [-W -2.6 3, -W 2.6 3, W 2.6 3, W -2.6 3];
H = [H, H + [0 0 -2, 0 0 -2, 0 0 -2, 0 0 -2]] * 0.393700;
fprintf(fid, 'in body1s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [-W+0.5 -2.1 3, -W+0.5 2.1 3, W-0.5 2.1 3, W-0.5 -2.1 3];
H = [H, H + [0 0 2.3, 0 0 2.3, 0 0 2.3, 0 0 2.3]] * 0.393700;
fprintf(fid, 'in body2s.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);



% Notch
H = [-W+0.5 -1.5 3, -W+0.5 1.5 3, -W 1.5 3, -W -1.5 3];
H = [H, H + [0 0 -2, 0 0 -2, 0 0 -2, 0 0 -2]] * 0.393700;
fprintf(fid, 'in body1h.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

% Connectors
for i = 1 : nrT
    H = [-1.27 * (nrT + 1) / 2 + i * 1.27, -(1 + 4 * (i / 2 - round(i / 2))) * 1, 5.3, 0, 0, -2, 0.8] * 0.393700;
    fprintf(fid, 'in body%dh.s rcc %g %g %g   %g %g %g   %g\n', [i + 1, H]);
end

% join regions
fprintf(fid, 'r bodys.r');
for i = 1 : 2
    fprintf(fid, ' u body%ds.s', i);
end
fprintf(fid, '\n');

fprintf(fid, 'r bodyh.r');
for i = 1 : (nrT + 1)
    fprintf(fid, ' u body%dh.s', i);
end
fprintf(fid, '\n');

%% Create the model
fprintf(fid, 'comb body.C u bodys.r - bodyh.r\n');

fprintf(fid, 'mater body.C "plastic" 153 255 127 0\n');

%% Create servo
fprintf(fid, 'comb %s.c u body.C\n', fn);
fclose(fid);


%% Render the wheel
unix(sprintf('%smged -c %s.g < %s.mged', folder, fn, fn));

for i = 15 : 15 : 360
    unix(sprintf('%srt -a -90 -e %g -w 200 -n 200 -C255/255/255 -o %s%03g.png %s.g arduino.c', folder, i, fn, i, fn));
end

unix(sprintf('convert -delay 20 -loop 0 %s???.png %s.gif', fn, fn));

unix(sprintf('chmod 644 %s???.png', fn));
unix(sprintf('rm %s???.png', fn));

%% Create and fix an STL file
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g %s.c', folder, fn, fn, fn));

unix(sprintf('../meshconv -c stl %s1.stl -o %s', fn, fn));

%unix(sprintf('rm %s1.stl', fn));

