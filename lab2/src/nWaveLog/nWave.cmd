wvResizeWindow -win $_nWave1 0 23 1920 1017
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/raid7_2/userb09/b09027/Digital-Circuit/lab2/src/lab2.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalSetScope -win $_nWave1 "/tb/Mont"
wvSetPosition -win $_nWave1 {("G1" 19)}
wvSetPosition -win $_nWave1 {("G1" 19)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb/Mont/N\[255:0\]} \
{/tb/Mont/a\[255:0\]} \
{/tb/Mont/b\[255:0\]} \
{/tb/Mont/counter_r\[7:0\]} \
{/tb/Mont/counter_w\[7:0\]} \
{/tb/Mont/i_N\[255:0\]} \
{/tb/Mont/i_a\[255:0\]} \
{/tb/Mont/i_b\[255:0\]} \
{/tb/Mont/i_clk} \
{/tb/Mont/i_input_ready} \
{/tb/Mont/i_rst} \
{/tb/Mont/m_r\[256:0\]} \
{/tb/Mont/m_w\[256:0\]} \
{/tb/Mont/o_m\[255:0\]} \
{/tb/Mont/o_output_ready} \
{/tb/Mont/o_ready_r} \
{/tb/Mont/o_ready_w} \
{/tb/Mont/state_r\[1:0\]} \
{/tb/Mont/state_w\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 )} 
wvSetPosition -win $_nWave1 {("G1" 19)}
wvGetSignalClose -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 1351.877074 -snap {("G1" 13)}
wvSetCursor -win $_nWave1 1245.549664 -snap {("G1" 13)}
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvSetCursor -win $_nWave1 1343.288525 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 1358.484096 -snap {("G1" 11)}
wvSetCursor -win $_nWave1 1349.366753 -snap {("G1" 13)}
wvSetCursor -win $_nWave1 1437.501068 -snap {("G1" 5)}
wvSetCursor -win $_nWave1 1337.210296 -snap {("G1" 8)}
wvSetCursor -win $_nWave1 1352.405867 -snap {("G1" 9)}
wvSetCursor -win $_nWave1 53814.719909 -snap {("G1" 14)}
wvSetCursor -win $_nWave1 53644.529508 -snap {("G1" 12)}
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvSetCursor -win $_nWave1 53544.698051 -snap {("G1" 12)}
wvSetCursor -win $_nWave1 53663.437698 -snap {("G1" 12)}
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvSetCursor -win $_nWave1 53545.111074 -snap {("G1" 13)}
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvSetCursor -win $_nWave1 53657.079443 -snap {("G1" 12)}
wvSetCursor -win $_nWave1 53562.568797 -snap {("G1" 12)}
wvResizeWindow -win $_nWave1 -154 83 1920 1061
wvZoom -win $_nWave1 51776.012716 51797.353829
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvResizeWindow -win $_nWave1 0 23 1920 1017
wvResizeWindow -win $_nWave1 -85 453 1920 1061
