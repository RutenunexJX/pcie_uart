proc ccf {Width Depth} {
    set ip_name "cdc_fifo_${Width}x${Depth}"

    if {[llength [get_ips -quiet $ip_name]] > 0} {
        puts "IP $ip_name already exists, skipping."
        return
    }

    create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 \
        -module_name $ip_name

    set_property -dict [list \
        CONFIG.Fifo_Implementation              {Independent_Clocks_Block_RAM} \
        CONFIG.Synchronization_Stages           {2} \
        CONFIG.Performance_Options              {First_Word_Fall_Through} \
        CONFIG.Input_Data_Width                 $Width \
        CONFIG.Input_Depth                      $Depth \
        CONFIG.Output_Data_Width                $Width \
        CONFIG.Reset_Type                       {Asynchronous_Reset} \
        CONFIG.Full_Flags_Reset_Value           {1} \
        CONFIG.Dout_Reset_Value                 {0} \
        CONFIG.Enable_Reset_Synchronization     {true} \
        CONFIG.Enable_Safety_Circuit            {true} \
        CONFIG.Almost_Full_Flag                 {false} \
        CONFIG.Almost_Empty_Flag                {false} \
        CONFIG.Write_Acknowledge_Flag           {false} \
        CONFIG.Overflow_Flag                    {false} \
        CONFIG.Valid_Flag                       {false} \
        CONFIG.Underflow_Flag                   {false} \
        CONFIG.Use_Extra_Logic                  {false} \
        CONFIG.Data_Count                       {false} \
        CONFIG.Write_Data_Count                 {false} \
        CONFIG.Read_Data_Count                  {false} \
        CONFIG.Programmable_Full_Type           {No_Programmable_Full_Threshold} \
        CONFIG.Programmable_Empty_Type          {No_Programmable_Empty_Threshold} \
    ] [get_ips $ip_name]

    generate_target all [get_ips $ip_name]
    puts "IP $ip_name created successfully."
}