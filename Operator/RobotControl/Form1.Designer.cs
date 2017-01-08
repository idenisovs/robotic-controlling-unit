namespace RobotControl
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.JoyX = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.JoyY = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.JoyZ = new System.Windows.Forms.TextBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.JoyCon = new System.Windows.Forms.TextBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.CtrlRcv = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.CtrlConn = new System.Windows.Forms.TextBox();
            this.TmrData = new System.Windows.Forms.Timer(this.components);
            this.label5 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // JoyX
            // 
            this.JoyX.Enabled = false;
            this.JoyX.Location = new System.Drawing.Point(31, 45);
            this.JoyX.Name = "JoyX";
            this.JoyX.Size = new System.Drawing.Size(100, 20);
            this.JoyX.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 48);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(14, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "X";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 74);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(14, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "Y";
            // 
            // JoyY
            // 
            this.JoyY.Enabled = false;
            this.JoyY.Location = new System.Drawing.Point(31, 71);
            this.JoyY.Name = "JoyY";
            this.JoyY.Size = new System.Drawing.Size(100, 20);
            this.JoyY.TabIndex = 2;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(11, 100);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(14, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Z";
            // 
            // JoyZ
            // 
            this.JoyZ.Enabled = false;
            this.JoyZ.Location = new System.Drawing.Point(31, 97);
            this.JoyZ.Name = "JoyZ";
            this.JoyZ.Size = new System.Drawing.Size(100, 20);
            this.JoyZ.TabIndex = 4;
            // 
            // timer1
            // 
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // JoyCon
            // 
            this.JoyCon.Enabled = false;
            this.JoyCon.Location = new System.Drawing.Point(31, 19);
            this.JoyCon.Name = "JoyCon";
            this.JoyCon.Size = new System.Drawing.Size(100, 20);
            this.JoyCon.TabIndex = 6;
            this.JoyCon.Text = "Disconnected";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.JoyCon);
            this.groupBox1.Controls.Add(this.JoyX);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.JoyZ);
            this.groupBox1.Controls.Add(this.JoyY);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(154, 141);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Joystick";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.label5);
            this.groupBox2.Controls.Add(this.CtrlRcv);
            this.groupBox2.Controls.Add(this.label4);
            this.groupBox2.Controls.Add(this.CtrlConn);
            this.groupBox2.Location = new System.Drawing.Point(172, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(197, 141);
            this.groupBox2.TabIndex = 8;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Controller";
            // 
            // CtrlRcv
            // 
            this.CtrlRcv.Enabled = false;
            this.CtrlRcv.Location = new System.Drawing.Point(65, 45);
            this.CtrlRcv.Name = "CtrlRcv";
            this.CtrlRcv.Size = new System.Drawing.Size(100, 20);
            this.CtrlRcv.TabIndex = 7;
            this.CtrlRcv.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(6, 22);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(37, 13);
            this.label4.TabIndex = 8;
            this.label4.Text = "Status";
            this.label4.Click += new System.EventHandler(this.label4_Click);
            // 
            // CtrlConn
            // 
            this.CtrlConn.Enabled = false;
            this.CtrlConn.Location = new System.Drawing.Point(65, 19);
            this.CtrlConn.Name = "CtrlConn";
            this.CtrlConn.Size = new System.Drawing.Size(100, 20);
            this.CtrlConn.TabIndex = 7;
            this.CtrlConn.Text = "Disconnected";
            // 
            // TmrData
            // 
            this.TmrData.Interval = 500;
            this.TmrData.Tick += new System.EventHandler(this.TmrData_Tick);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(6, 48);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(53, 13);
            this.label5.TabIndex = 9;
            this.label5.Text = "Received";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(596, 324);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.Load += new System.EventHandler(this.Form1_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TextBox JoyX;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox JoyY;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox JoyZ;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.TextBox JoyCon;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.TextBox CtrlConn;
        private System.Windows.Forms.Timer TmrData;
        private System.Windows.Forms.TextBox CtrlRcv;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
    }
}

