fn = 'CR2032';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');

%% Coil body
H = [-13.97 3.175 0, 13.97 3.175 0, 13.97 -3.175 0, -13.97 -3.175 0];
H = [H, H + [0 0 4, 0 0 4, 0 0 4, 0 0 4]];
fprintf(fid, 'in body1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [-10.795 -5.715 0, 10.795 -5.715 0, 10.795 -8.255 0, -10.795 -8.255 0];
H = [H, H + [0 0 4, 0 0 4, 0 0 4, 0 0 4]];
fprintf(fid, 'in body2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [-10.795 8.255 0, 10.795 8.255 0, 10.795 -5.725 0, -10.795 -5.725 0];
H = [H, H + [0 0 4, 0 0 4, 0 0 4, 0 0 4]];
fprintf(fid, 'in body3.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
fprintf(fid, 'r body.r u body1.s u body2.s u body3.s\n');

I = H([4 5]) - 1.5;
fprintf(fid, 'in plus1.s rcc %g %g 4   0 0 -0.5   1.2\n', I);
H = repmat([I 4.2], 1, 4) + [-0.9 -0.2 0, 0.9 -0.2 0, 0.9 0.2 0, -0.9 0.2 0];
H = [H, H + [0 0 -0.7, 0 0 -0.7, 0 0 -0.7, 0 0 -0.7]];
fprintf(fid, 'in plus2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
H = repmat([I 4.2], 1, 4) + [-0.2 -0.9 0, 0.2 -0.9 0, 0.2 0.9 0, -0.2 0.9 0];
H = [H, H + [0 0 -0.7, 0 0 -0.7, 0 0 -0.7, 0 0 -0.7]];
fprintf(fid, 'in plus3.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
fprintf(fid, 'r plus.r u plus1.s - plus2.s - plus3.s\n');

fprintf(fid, 'in minus1.s rcc %g %g 4.1   0 0 -0.5   1.2\n', -I);
H = repmat([-I 4.2], 1, 4) + [-0.9 -0.2 0, 0.9 -0.2 0, 0.9 0.2 0, -0.9 0.2 0];
H = [H, H + [0 0 -0.7, 0 0 -0.7, 0 0 -0.7, 0 0 -0.7]];
fprintf(fid, 'in minus2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
fprintf(fid, 'r minus.r u minus1.s - minus2.s\n');

fprintf(fid, 'in battery.s rcc 0 0 4   0 0 -3.1   9.95\n');


%% Create the model
fprintf(fid, 'comb body.C u body.r - minus.r - plus.r - battery.s\n');
fprintf(fid, 'comb battery.C u battery.s\n');
fprintf(fid, 'mater body.C "plastic" 255 253 208 0\n');
fprintf(fid, 'mater battery.C "metal" 255 255 255 0\n');

%% Create servo
fprintf(fid, 'comb CR2032.c u body.C u battery.C\n');
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
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g CR2032.c', folder, fn, fn));
unix(sprintf('%sg-stl -a 0.05 -o battery1.stl %s.g battery.C', folder, fn));
unix(sprintf('%sg-stl -a 0.05 -o body1.stl %s.g body.C', folder, fn));

unix(sprintf('./meshconv -c stl body1.stl -o body'));
unix(sprintf('./meshconv -c stl battery1.stl -o battery'));
unix(sprintf('./meshconv -c stl %s1.stl -o %s', fn, fn));

%unix(sprintf('rm %s1.stl', fn));

