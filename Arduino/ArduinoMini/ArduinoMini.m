fn = 'arduino';
folder = '/usr/brlcad/bin/';

delete([fn '.g']);
fid = fopen([fn '.mged'], 'w');

%% Coil body
H = [0 0 0, 17.78 0 0, 17.78 33.02 0, 0 33.02 0];
H = [H, H + [0 0 1.2, 0 0 1.2, 0 0 1.2, 0 0 1.2]];
fprintf(fid, 'in PCBs.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
X = [1.27 : 2.54 : (11.5 * 2.54), 12.5 * ones(1, 6) * 2.54, (11.5 * 2.54) : -2.54 : 1.27, [7 8] * 2.54];
Y = [1.27 * ones(1, 12), 2.54 : 2.54 : (6 * 2.54), 6.5 * 2.54 * ones(1, 12), [1 1] * 5.5 * 2.54];
for i = 1 : numel(X)
    fprintf(fid, 'in pads%02d.s rcc %g %g 0   0 0 1.2 0.8\n', i, Y(i), X(i));
    fprintf(fid, 'in padh%02d.s rcc %g %g 0   0 0 1.2 0.5\n', i, Y(i), X(i));
end

fprintf(fid, 'r pads.r');
for i = 1 : numel(X)
    fprintf(fid, ' u pads%02d.s', i);
end
fprintf(fid, '\n');

fprintf(fid, 'r padh.r');
for i = 1 : numel(X)
    fprintf(fid, ' u padh%02d.s', i);
end
fprintf(fid, '\n');

H = [3.81 13.97 1.2, 8.89 9.144 1.2, 13.716 13.97 1.2, 8.89 18.796 1.2];
H = [H, H + [0.4 0 1, 0 0.4 1, -0.4 0 1, 0 -0.4 1]];
fprintf(fid, 'in chips1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [8.382 18.288 1.2, 9.398 18.288 1.2, 9.398 18.288 2.2, 8.382 18.288 2.2, 8.89 18.796 1.2, 8.89 18.796 2.2];
fprintf(fid, 'in chiph1.s arb6 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [8.128 22.606 1.2, 9.652 22.606 1.2, 9.652 25.654 1.2, 8.128 25.654 1.2 ];
H = [H, H + [0 0 0.5, 0 0 0.5, 0 0 0.5, 0 0 0.5]];
fprintf(fid, 'in chips2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [3.810 21.59 1.2, 6.35 21.59 1.2, 6.35 26.67 1.2, 3.810 26.67 1.2];
H = [H, H + [0 0 1.5, 0 0 1.5, 0 0 1.5, 0 0 1.5]];
fprintf(fid, 'in caps1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [12.192 21.59 1.2, 14.732 21.59 1.2, 14.732 26.67 1.2, 12.192 26.67 1.2];
H = [H, H + [0 0 1.5, 0 0 1.5, 0 0 1.5, 0 0 1.5]];
fprintf(fid, 'in caps2.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);

H = [6.35 1.27 1.2, 11.43 1.27 1.2, 11.43 6.35 1.2, 6.35 6.35 1.2];
H = [H, H + [0 0 1.5, 0 0 1.5, 0 0 1.5, 0 0 1.5]];
fprintf(fid, 'in switchs1.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);
fprintf(fid, 'in switchs2.s rcc 8.89 3.81 2.7   0 0 1   1.4\n');

H = [3.084 17.78 1.2, 4.572 17.78 1.2, 4.572 21.082 1.2, 3.084 21.082 1.2];
H = [H, H + [0 0 1.5, 0 0 1.5, 0 0 1.5, 0 0 1.5]];
fprintf(fid, 'in switchs3.s arb8 %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g   %g %g %g\n', H);


%% Create the model
fprintf(fid, 'comb PCB.C u PCBs.s - pads.r\n');
fprintf(fid, 'comb pad.C u pads.r - padh.r\n');
fprintf(fid, 'r chips.r u chips1.s u chips2.s\n');
fprintf(fid, 'comb chip.C u chips.r - chiph1.s\n');
fprintf(fid, 'comb cap.C u caps1.s u caps2.s\n');
fprintf(fid, 'comb switch.C u switchs1.s u switchs2.s u switchs3.s\n');
fprintf(fid, 'mater PCB.C "plastic" 0 0 255 0\n');
fprintf(fid, 'mater pad.C "metal" 255 255 255 0\n');
fprintf(fid, 'mater chip.C "plastic" 0 0 0 0\n');
fprintf(fid, 'mater cap.C "plastic" 255 255 0 0\n');
fprintf(fid, 'mater switch.C "metal" 255 255 127 0\n');

%% Create servo
fprintf(fid, 'comb arduino.c u PCB.C u pad.C u chip.C u cap.C u switch.C\n');
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
unix(sprintf('%sg-stl -a 0.05 -o %s1.stl %s.g arduino.c', folder, fn, fn));
unix(sprintf('%sg-stl -a 0.05 -o PCB1.stl %s.g PCB.C', folder, fn));
unix(sprintf('%sg-stl -a 0.05 -o pad1.stl %s.g pad.C', folder, fn));

unix(sprintf('./meshconv -c stl %s1.stl -o %s.stl', fn, fn));
unix('./meshconv -c stl PCB1.stl -o PCB.stl');
unix('./meshconv -c stl pad1.stl -o pad.stl');

unix(sprintf('rm %s1.stl', fn));

