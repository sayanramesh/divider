# SimVision command script divider.tcl for divider
database -open waves
probe -all -depth all -database waves
run
simvision {
# List of signals to monitor defined here
#
set wave_signal_list {
  divider_stim.Clock
  divider_stim.nReset
  divider_stim.Req
  divider_stim.Done
  divider_stim.Operand1
  divider_stim.Operand2
  divider_stim.Quotient
  divider_stim.Remainder
}
# View Results
#
window new WaveWindow -name "Waves for magic cell divider"
waveform add -using "Waves for magic cell divider" -signals $wave_signal_list
waveform xview zoom -using "Waves for magic cell divider" -outfull
}
