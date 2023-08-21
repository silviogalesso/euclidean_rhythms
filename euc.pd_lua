local euc = pd.Class:new():register("euc")


function euc:initialize(sel, atoms)
    self.inlets = 5
    self.outlets = 2
    self.steps = 16
    self.beats = 0
    self.rotation = 0
    self.pad = 0
    self.accents = 0
    self.sequence = {}
    return true
end

function euc:in_1_float(beats)
    self.beats = beats
    self:compute()
end

function euc:in_2_float(rotation)
    self.rotation = rotation
    self:compute()
end

function euc:in_3_float(pad)
    self.pad = pad
    self:compute()
end

function euc:in_4_float(accents)
    self.accents = accents
    self:compute()
end

function euc:in_5_float(steps)
    self.steps = steps
    self:compute()
end


function rotate(sequence, rotation)
    local output = {}
    for j = 1,#sequence,1
    do
        output[1+(((j-1)+rotation)%#sequence)] = sequence[j]
    end
    return output
end


function euc:euc(beats, steps)
    -- Euclidean algorithm... https://www.youtube.com/watch?v=8-vakfQ-qlk
    local sequence = {}
    local residues = {}
    
    -- degenerate case
    if beats >= steps
    then
        for j = 1,steps,1
        do
            sequence[j] = 1
        end
    else
        for i = 1,steps+1,1
        do
            -- should start from -1
            base_index = i-2
            residues[i] = (base_index*beats)%steps
        end
        
        for j = 1,steps,1
        do
            sequence[j] = (residues[j]>residues[j+1]) and 1 or 0
        end
    end
    
    return sequence
end


function euc:euc_pad(beats, steps, pad, accents)
    sequence = self:euc(beats, steps-pad)
    accents = self:euc(accents, beats)

    local accents_counter = 1
    for i = 1,#sequence,1
    do
        if (sequence[i]==1)
        then
            sequence[i] = sequence[i]+accents[accents_counter]
            pd.post(string.format("%g %g %g", accents_counter, accents[accents_counter], sequence[i]))
            accents_counter = accents_counter+1
        end
    end
    
    for p = steps-pad+1,steps,1
    do
        sequence[p] = 0
    end
    return sequence
end

function euc:compute()
    -- send number of steps to outlet
    self:outlet(2, "float", {self.steps})
    
    self.sequence = rotate(self:euc_pad(self.beats, self.steps, self.pad, self.accents), self.rotation)
    
    -- send sequence to outlet
    for j = 1,self.steps,1
    do
        -- self:outlet(1, "list", {self.sequence[1+(((j-1)-self.rotation)%self.steps)], j-1})
        self:outlet(1, "list", {self.sequence[j], j-1})
        -- pd.post(string.format("%g %g", self.sequence[j], j-1))
    end
end


