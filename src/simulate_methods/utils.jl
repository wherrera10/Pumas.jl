function adjust_event_timings!(events,lags,bioav,rate,duration)
  for i in eachindex(events)
    ev = events[i]
    ev.rate != 0 ? duration = ev.amt/ev.rate : duration = zero(ev.amt)
    if ev.off_event
      typeof(bioav) <: Number ? time = ev.base_time + bioav*duration :
                                time = ev.base_time + bioav[ev.cmt]*duration
    else
      time = ev.base_time
    end
    typeof(lags) <: Number ? (time+=lags) : (time+=lags[ev.cmt])
    events[i] = Event(ev.amt,time,ev.evid, ev.cmt, ev.rate,
                      ev.ss, ev.ii, ev.base_time, ev.off_event)
  end
  sort!(events)
end

function sorted_approx_unique(event)
  tType = typeof(first(event).time)
  out = Vector{typeof(first(event).time)}(1)
  out[1] = event[1].time
  for i in 2:length(event)
    if abs(out[end] - event[i].time) > 10eps(tType)
      push!(out,event[i].time)
    end
  end
  out
end

function set_value(A :: SVector{L,T}, x,k) where {T,L}
    SVector(ntuple(i->ifelse(i == k, x, A[i]), Val{L}))
end

function increment_value(A :: SVector{L,T}, x,k) where {T,L}
    SVector(ntuple(i->ifelse(i == k, A[i]+x, A[i]), Val{L}))
end

function increment_value(A::Number,x,k)
  A+x
end

function get_magic_args(p,u0,t0)
  if haskey(p,:lags)
    lags = p.lags
  else
    lags = zero(eltype(t0))
  end

  if haskey(p,:bioav)
    bioav = p.bioav
  else
    bioav = one(eltype(u0))
  end

  if haskey(p,:rate)
    rate = p.rate
  else
    rate = zero(eltype(u0))
  end

  if haskey(p,:duration)
    duration = p.duration
  else
    duration = zero(eltype(u0))
  end

  lags,bioav,rate,duration
end
